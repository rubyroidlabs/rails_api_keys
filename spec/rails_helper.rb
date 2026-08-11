# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"

require "spec_helper"
require_relative "dummy/config/environment"
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "rspec/rails"

Dir[File.expand_path("support/**/*.rb", __dir__)].sort.each { |f| require f }

RSpec.configure do |config|
  config.fixture_paths = []
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.before(:suite) do
    ActiveRecord::Migration.verbose = false
    ActiveRecord::Schema.define do
      create_table :users, force: true do |t|
        t.string :email, null: false
        t.boolean :active, null: false, default: true
        t.timestamps
      end

      create_table :organizations, force: true do |t|
        t.string :name
        t.timestamps
      end

      create_table :companies, force: true do |t|
        t.string :name, null: false
        t.timestamps
      end

      create_table :rails_api_keys_api_keys, force: true do |t|
        t.string :name, null: false
        t.string :token_digest, null: false
        t.string :token_display_prefix, null: false
        t.string :permission, null: false, default: "read"
        t.references :owner, polymorphic: true, null: false, index: true
        t.datetime :revoked_at
        t.datetime :last_used_at
        t.timestamps
      end

      add_index :rails_api_keys_api_keys, :token_digest, unique: true
      add_index :rails_api_keys_api_keys, :revoked_at
    end
  end

  config.before do
    RailsApiKeys.reset_configuration!
  end
end
