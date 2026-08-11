# frozen_string_literal: true

module RailsApiKeys
  class Engine < ::Rails::Engine
    isolate_namespace RailsApiKeys

    initializer "rails_api_keys.active_record" do
      ActiveSupport.on_load(:active_record) do
        include RailsApiKeys::Owner
      end
    end
  end
end
