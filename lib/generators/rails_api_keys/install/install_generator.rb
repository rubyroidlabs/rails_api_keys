# frozen_string_literal: true

require "rails/generators"
require "rails/generators/migration"

module RailsApiKeys
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      source_root File.expand_path("templates", __dir__)

      desc "Install RailsApiKeys migrations and initializer"

      def self.next_migration_number(dirname)
        next_number = Time.now.utc.strftime("%Y%m%d%H%M%S")
        if Dir.exist?(dirname)
          while Dir.children(dirname).any? { |f| f.start_with?(next_number) }
            next_number = (next_number.to_i + 1).to_s
          end
        end
        next_number
      end

      def copy_migration
        migration_template(
          "create_rails_api_keys_api_keys.rb.tt",
          "db/migrate/create_rails_api_keys_api_keys.rb"
        )
      end

      def copy_initializer
        template "initializer.rb.tt", "config/initializers/rails_api_keys.rb"
      end
    end
  end
end
