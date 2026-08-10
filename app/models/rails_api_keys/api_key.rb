# frozen_string_literal: true

require "digest"
require "securerandom"

module RailsApiKeys
  class ApiKey < ApplicationRecord
    self.table_name = "rails_api_keys_api_keys"

    DISPLAY_PREFIX_LENGTH = 12
    TOKEN_BYTES = 32

    belongs_to :owner, polymorphic: true

    enum :permission, { read: "read", read_write: "read_write" }, validate: true

    validates :name, :token_digest, :token_display_prefix, :permission, presence: true
    validates :token_digest, uniqueness: true
    validate :owner_matches_configured_class
    validate :permission_immutable, on: :update

    scope :active, -> { where(revoked_at: nil) }

    class << self
      def generate_for!(owner:, name:, permission:)
        raw_token = build_raw_token
        record = create!(
          owner: owner,
          name: name,
          permission: permission,
          token_digest: digest(raw_token),
          token_display_prefix: display_prefix_for(raw_token)
        )
        [ record, raw_token ]
      end

      def authenticate(raw_token)
        return if raw_token.blank?

        key = active.find_by(token_digest: digest(raw_token))
        return unless key
        return unless RailsApiKeys.configuration.owner_active?(key.owner)

        key.touch_last_used!
        key
      end

      def digest(raw_token)
        Digest::SHA256.hexdigest(raw_token.to_s)
      end

      def build_raw_token
        "#{RailsApiKeys.configuration.resolved_token_prefix}#{SecureRandom.urlsafe_base64(TOKEN_BYTES)}"
      end

      def display_prefix_for(raw_token)
        raw_token.to_s[0, DISPLAY_PREFIX_LENGTH]
      end
    end

    def revoke!
      update!(revoked_at: Time.current)
    end

    def revoked?
      revoked_at.present?
    end

    def active?
      !revoked?
    end

    def allows_read?
      read? || read_write?
    end

    def allows_write?
      read_write?
    end

    def touch_last_used!
      update_column(:last_used_at, Time.current)
    end

    private

    def owner_matches_configured_class
      return if owner.blank?

      expected = RailsApiKeys.configuration.owner_class_name
      return if owner.class.name == expected

      errors.add(:owner, "must be a #{expected}")
    end

    def permission_immutable
      return unless permission_changed? && persisted?

      errors.add(:permission, "cannot be changed after creation")
    end
  end
end
