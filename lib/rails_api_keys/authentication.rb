# frozen_string_literal: true

require "active_support/concern"

module RailsApiKeys
  module Authentication
    extend ActiveSupport::Concern


    included do
      attr_reader :current_api_key, :current_api_owner
    end

    private

    def authenticate_api_key!
      token = bearer_token
      key = RailsApiKeys::ApiKey.authenticate(token)

      unless key
        render_api_unauthorized
        return false
      end

      @current_api_key = key
      @current_api_owner = key.owner
      true
    end

    def require_api_permission!(level)
      allowed =
        case level.to_sym
        when :read then current_api_key&.allows_read?
        when :write then current_api_key&.allows_write?
        else false
        end

      return true if allowed

      render json: { error: "Forbidden" }, status: :forbidden
      false
    end

    def bearer_token
      header = request.authorization.to_s
      return unless header.match?(/\ABearer\s+/i)

      header.split(/\s+/, 2).last.presence
    end

    def render_api_unauthorized
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end
end
