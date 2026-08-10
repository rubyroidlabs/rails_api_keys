# frozen_string_literal: true

class User < ApplicationRecord
  has_many :api_keys, as: :owner, class_name: "RailsApiKeys::ApiKey", dependent: :destroy

  def active_for_authentication?
    active?
  end
end
