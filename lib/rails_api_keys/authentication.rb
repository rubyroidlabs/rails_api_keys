# frozen_string_literal: true

require "active_support/concern"

module RailsApiKeys
  # Controller concern for +ActionController::API+.
  #
  # Include and call {#authenticate_api_key!} from +before_action+. After a
  # successful authenticate, +current_api_key+ and +current_api_owner+ are set.
  # Permission is enforced from the HTTP method: GET/HEAD require read; other
  # methods require write.
  #
  # Expects +Authorization: Bearer <raw_token>+.
  module Authentication
    extend ActiveSupport::Concern

    included do
      attr_reader :current_api_key, :current_api_owner
    end

    private

    # Authenticates the Bearer token and enforces method-based permission.
    # Renders 401 on auth failure, 403 when the key lacks the required level.
    def authenticate_api_key!
      token = bearer_token
      key = RailsApiKeys::ApiKey.authenticate(token)

      unless key
        render_api_unauthorized
        return false
      end

      @current_api_key = key
      @current_api_owner = key.owner
      enforce_api_permission!
    end

    def enforce_api_permission!
      allowed =
        if request.get? || request.head?
          current_api_key.allows_read?
        else
          current_api_key.allows_write?
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
