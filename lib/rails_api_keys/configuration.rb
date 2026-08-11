# frozen_string_literal: true

module RailsApiKeys
  # Optional host overrides. Set via {RailsApiKeys.configure}.
  #
  # Defaults: +token_prefix+ derives from the app name, and +owner_active+ uses
  # Devise-style +active_for_authentication?+ when available.
  # Owner models opt in with {Owner.has_api_keys}.
  class Configuration
    attr_accessor :token_prefix, :owner_active

    def initialize
      @token_prefix = nil
      @owner_active = ->(owner) {
        if owner.respond_to?(:active_for_authentication?)
          owner.active_for_authentication?
        else
          true
        end
      }
    end

    def resolved_token_prefix
      return token_prefix.to_s if token_prefix.present?

      "#{Rails.application.class.module_parent_name.downcase}_ak_"
    end

    def owner_active?(owner)
      owner_active.call(owner)
    end
  end
end
