# frozen_string_literal: true

module RailsApiKeys
  # Mixes {.has_api_keys} into Active Record so host models can opt in as key owners.
  module Owner
    extend ActiveSupport::Concern

    class_methods do
      # Declares a polymorphic +has_many :api_keys+ and registers this class as an
      # allowed owner for {RailsApiKeys::ApiKey}.
      def has_api_keys(dependent: :destroy)
        has_many :api_keys,
                 as: :owner,
                 class_name: "RailsApiKeys::ApiKey",
                 dependent: dependent

        RailsApiKeys.register_owner_class!(self)
      end
    end
  end
end
