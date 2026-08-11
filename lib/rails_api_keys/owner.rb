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

        # Creates a key for this owner and returns +[record, raw_token]+.
        define_method(:create_api_key!) do |name:, permission:|
          RailsApiKeys::ApiKey.generate_for!(owner: self, name: name, permission: permission)
        end
      end
    end
  end
end
