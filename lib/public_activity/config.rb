# frozen_string_literal: true

require 'singleton'

module PublicActivity
  # Class used to initialize configuration object.
  class Config
    include ::Singleton

    # Evaluates given block to provide DSL configuration.
    # @example Initializer for Rails
    #   PublicActivity::Config.set do
    #     orm :mongo_mapper
    #     enabled false
    #     table_name "activities"
    #     parameters_type :json
    #   end
    def self.set(&block)
      b = Block.new
      b.instance_eval(&block)
      instance
      orm(b.orm) unless b.orm.nil?
      enabled(b.enabled) unless b.enabled.nil?
      table_name(b.table_name) unless b.table_name.nil?
      parameters_type(b.parameters_type) unless b.parameters_type.nil?
    end

    # alias for {#orm}
    # @see #orm
    def self.orm=(orm = nil)
      orm(orm)
    end

    # alias for {#enabled}
    # @see #enabled
    def self.enabled=(value = nil)
      enabled(value)
    end

    # alias for {#parameters_type}
    # @see #parameters_type
    def self.parameters_type=(type = nil)
      parameters_type(type)
    end

    # instance version of {Config#orm}
    # @see Config#orm
    def orm(orm = nil)
      self.class.orm(orm)
    end

    # instance version of {Config#table_name}
    # @see Config#orm
    def table_name(name = nil)
      self.class.table_name(name)
    end

    # instance version of {Config#enabled}
    # @see Config#orm
    def enabled(value = nil)
      self.class.enabled(value)
    end

    # instance version of {Config#parameters_type}
    # @see Config#parameters_type
    def parameters_type(type = nil)
      self.class.parameters_type(type)
    end

    # Set the ORM for use by PublicActivity.
    def self.orm(orm = nil)
      if orm.nil?
        Thread.current[:public_activity_orm] || :active_record
      else
        Thread.current[:public_activity_orm] = orm.to_sym
      end
    end

    def self.table_name(name = nil)
      if name.nil?
        Thread.current[:public_activity_table_name] || "activities"
      else
        Thread.current[:public_activity_table_name] = name
      end
    end

    def self.enabled(value = nil)
      if value.nil?
        val = Thread.current[:public_activity_enabled]
        val.nil? ? true : val
      else
        Thread.current[:public_activity_enabled] = value
      end
    end

    # Sets the column type of the activity +parameters+ column.
    #
    # When set, PublicActivity trusts this instead of inspecting the database
    # schema, so that loading the Activity class does not open a database
    # connection. Leave unset (+nil+) to detect the type from the schema.
    def self.parameters_type(type = nil)
      if type.nil?
        Thread.current[:public_activity_parameters_type]
      else
        Thread.current[:public_activity_parameters_type] = type.to_sym
      end
    end

    # Provides simple DSL for the config block.
    class Block
      # @see Config#orm
      def orm(orm = nil)
        @orm = (orm ? orm.to_sym : false) || @orm
      end

      # Decides whether to enable PublicActivity.
      # @param en [Boolean] Enabled?
      def enabled(value = nil)
        @enabled = (value.nil? ? @enabled : value)
      end

      # Sets the table_name for the model
      def table_name(name = nil)
        @table_name = (name.nil? ? @table_name : name)
      end

      # Sets the column type of the activity parameters column
      def parameters_type(type = nil)
        @parameters_type = (type.nil? ? @parameters_type : type)
      end
    end
  end
end
