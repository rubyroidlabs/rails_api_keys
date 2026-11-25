# frozen_string_literal: true

class AddAllowedIpsToRailsApiKeysApiKeys < ActiveRecord::Migration[7.0]
  def change
    add_column :rails_api_keys_api_keys, :allowed_ips, :json, null: false, default: []
  end
end
