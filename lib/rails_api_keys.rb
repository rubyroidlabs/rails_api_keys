# frozen_string_literal: true

require "set"
require "rails_api_keys/version"
require "rails_api_keys/configuration"
require "rails_api_keys/authentication"
require "rails_api_keys/owner"
require "rails_api_keys/engine"

# Thin Rails engine for personal API key authentication.
#
# @see file:README.md
module RailsApiKeys
  class << self
    # @return [RailsApiKeys::Configuration]
    def configuration
      @configuration ||= Configuration.new
    end

    # Yields {configuration} for host overrides in an initializer.
    def configure
      yield configuration
    end

    # Resets configuration to defaults (primarily for tests).
    # Does not clear {.owner_class_names}; those are registered at model load via {Owner#has_api_keys}.
    def reset_configuration!
      @configuration = Configuration.new
    end

    # Records +klass+ as an allowed API key owner (idempotent).
    def register_owner_class!(klass)
      owner_class_names << klass.name
    end

    # @return [Boolean] whether +klass+ (or its name) called {Owner#has_api_keys}
    def owner_class?(klass)
      name = klass.is_a?(Module) ? klass.name : klass.to_s
      owner_class_names.include?(name)
    end

    # @return [Set<String>] registered owner class names
    def owner_class_names
      @owner_class_names ||= Set.new
    end
  end
end
