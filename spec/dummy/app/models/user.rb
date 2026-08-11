# frozen_string_literal: true

class User < ApplicationRecord
  has_api_keys

  def active_for_authentication?
    active?
  end
end
