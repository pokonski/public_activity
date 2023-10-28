# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'public_activity/version'

Gem::Specification.new do |s|
  s.name = 'public_activity'
  s.version = PublicActivity::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ['Piotrek Okoński', 'Kuba Okoński']
  s.email = 'piotrek@okonski.org'
  s.homepage = 'https://github.com/pokonski/public_activity'
  s.summary = 'Easy activity tracking for ActiveRecord models'
  s.description = 'Easy activity tracking for your ActiveRecord models. Provides Activity model with details about actions performed by your users, like adding comments, responding etc.'
  s.license = 'MIT'
  s.metadata = {
    'changelog_uri' => 'https://github.com/public-activity/public_activity/blob/main/CHANGELOG.md'
  }

  s.files = `git ls-files lib`.split("\n") + ['Gemfile', 'Rakefile', 'README.md', 'MIT-LICENSE']
  s.test_files = `git ls-files test`.split("\n")
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 3.0.0'

  s.post_install_message = File.read('UPGRADING') if File.exist?('UPGRADING')

  s.add_dependency 'actionpack', '>= 6.1.0'
  s.add_dependency 'i18n', '>= 0.5.0'
  s.add_dependency 'railties', '>= 6.1.0'

  ENV['PA_ORM'] ||= 'active_record'
  case ENV['PA_ORM']
  when 'active_record'
    s.add_dependency 'activerecord', '>= 6.1'
  when 'mongoid'
    s.add_dependency 'mongoid',      '>= 4.0'
  when 'mongo_mapper'
    s.add_dependency 'bson_ext'
    s.add_dependency 'mongo', '<= 1.9.2'
    s.add_dependency 'mongo_mapper', '>= 0.12.0'
  end

  s.add_development_dependency 'appraisal'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'redcarpet'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'sqlite3', '>= 1.4.1'
  s.add_development_dependency 'test-unit'
  s.add_development_dependency 'yard'
end
