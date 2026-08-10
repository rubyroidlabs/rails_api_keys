# frozen_string_literal: true

module Api
  module V1
    class PingController < ActionController::API
      include RailsApiKeys::Authentication

      before_action :authenticate_api_key!
      before_action -> { require_api_permission!(permission_level) }

      def show
        render json: {
          owner_id: current_api_owner.id,
          permission: current_api_key.permission
        }
      end

      private

      def permission_level
        params[:required_permission].presence || :read
      end
    end
  end
end
