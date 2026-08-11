# frozen_string_literal: true

module Api
  module V1
    class PingController < ActionController::API
      include RailsApiKeys::Authentication

      before_action :authenticate_api_key!

      def show
        render json: {
          owner_id: current_api_owner.id,
          permission: current_api_key.permission
        }
      end

      def create
        render json: {
          owner_id: current_api_owner.id,
          permission: current_api_key.permission
        }, status: :created
      end
    end
  end
end
