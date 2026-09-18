# frozen_string_literal: true

if ENV['PA_ORM'] == 'active_record'

  require 'test_helper'

  describe 'PublicActivity.parameters_type' do
    def activity_class
      PublicActivity::Activity # triggers the ORM-specific autoload
      PublicActivity::ORM::ActiveRecord::Activity
    end

    def activity_source
      File.expand_path('../lib/public_activity/orm/active_record/activity.rb', __dir__)
    end

    # The option is only read while the Activity class body runs, so these tests
    # re-load that file to exercise it. Reopening the class redefines its
    # associations, which is noisy but harmless.
    def reload_activity_class
      verbose = $VERBOSE
      $VERBOSE = nil
      load activity_source
    ensure
      $VERBOSE = verbose
    end

    # Records how loading the class inspected the schema, without leaving the
    # overrides in place for the next test.
    def schema_lookups_while_loading
      lookups = []
      activity_class.define_singleton_method(:table_exists?) { lookups << :table_exists?; true }
      activity_class.define_singleton_method(:columns_hash) do
        lookups << :columns_hash
        { 'parameters' => Struct.new(:type).new(:text) }
      end
      reload_activity_class
      lookups
    ensure
      activity_class.singleton_class.send(:remove_method, :table_exists?, :columns_hash)
    end

    def serialize_calls_while_loading
      calls = []
      activity_class.define_singleton_method(:serialize) { |*args, **opts| calls << [args, opts] }
      reload_activity_class
      calls
    ensure
      activity_class.singleton_class.send(:remove_method, :serialize)
    end

    before { Thread.current[:public_activity_parameters_type] = nil }

    after do
      Thread.current[:public_activity_parameters_type] = nil
      reload_activity_class # restore schema-derived serialization for other tests
    end

    it 'is unset by default' do
      assert_nil PublicActivity.parameters_type
    end

    it 'is writable through PublicActivity' do
      PublicActivity.parameters_type = :json
      assert_equal :json, PublicActivity.parameters_type
    end

    it 'is writable through Config, and symbolizes the value' do
      PublicActivity::Config.parameters_type = 'jsonb'
      assert_equal :jsonb, PublicActivity.parameters_type
    end

    it 'is writable through the Config DSL' do
      PublicActivity::Config.set { parameters_type :hstore }
      assert_equal :hstore, PublicActivity.parameters_type
    end

    it 'inspects the database schema when unset' do
      assert_includes schema_lookups_while_loading, :table_exists?
    end

    it 'never touches the database when set' do
      PublicActivity.parameters_type = :text
      assert_empty schema_lookups_while_loading
    end

    it 'serializes the column for non-structured types' do
      PublicActivity.parameters_type = :text
      refute_empty serialize_calls_while_loading
    end

    %i[json jsonb hstore].each do |type|
      it "leaves the column alone for #{type}" do
        PublicActivity.parameters_type = type
        assert_empty serialize_calls_while_loading
      end
    end
  end
end
