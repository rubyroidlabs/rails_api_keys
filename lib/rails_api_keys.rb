# frozen_string_literal: true

require "rails_api_keys/version"
require "rails_api_keys/configuration"
require "rails_api_keys/authentication"
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
    def reset_configuration!
      @configuration = Configuration.new
    end
  end
end
