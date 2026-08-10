# frozen_string_literal: true

require "rails_api_keys/version"
require "rails_api_keys/configuration"
require "rails_api_keys/authentication"
require "rails_api_keys/engine"

module RailsApiKeys
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield configuration
    end

    def reset_configuration!
      @configuration = Configuration.new
    end
  end
end
