# frozen_string_literal: true

require "digest"
require "securerandom"

module RailsApiKeys
  # Persists personal API keys for a polymorphic owner.
  #
  # Raw tokens are returned only from {.generate_for!} and are never stored.
  # Authentication matches against a SHA-256 digest and refuses revoked or
  # inactive-owner keys.
  class ApiKey < ApplicationRecord
    self.table_name = "rails_api_keys_api_keys"

    DISPLAY_PREFIX_LENGTH = 12
    TOKEN_BYTES = 32

    belongs_to :owner, polymorphic: true

    enum :permission, { read: "read", read_write: "read_write" }, validate: true

    validates :name, :token_digest, :token_display_prefix, :permission, presence: true
    validates :token_digest, uniqueness: true
    validate :owner_declares_has_api_keys
    validate :permission_immutable, on: :update
    validate :allowed_ips_must_be_valid

    scope :active, -> { where(revoked_at: nil) }

    class << self
      # Creates a key and returns +[record, raw_token]+. Show +raw_token+ once.
      def generate_for!(owner:, name:, permission:, allowed_ips: [])
        raw_token = build_raw_token
        record = create!(
          owner: owner,
          name: name,
          permission: permission,
          allowed_ips: allowed_ips,
          token_digest: digest(raw_token),
          token_display_prefix: display_prefix_for(raw_token)
        )
        [ record, raw_token ]
      end

      # Returns an active key for +raw_token+, or +nil+. Touches +last_used_at+
      # unless +touch_last_used: false+.
      def authenticate(raw_token, touch_last_used: true)
        return if raw_token.blank?

        key = active.find_by(token_digest: digest(raw_token))
        return unless key
        return unless RailsApiKeys.configuration.owner_active?(key.owner)

        key.touch_last_used! if touch_last_used
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

    def allowed_ips=(value)
      super(IpAllowlist.new(value).entries)
    end

    # Soft-revokes the key so {.authenticate} no longer accepts it.
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

    def allows_ip?(ip)
      IpAllowlist.new(allowed_ips).allows?(ip)
    end

    def touch_last_used!
      update_column(:last_used_at, Time.current)
    end

    private

    def allowed_ips_must_be_valid
      IpAllowlist.new(allowed_ips).invalid_entries.each do |entry|
        errors.add(:allowed_ips, "contains invalid IP address or CIDR: #{entry}")
      end
    end

    def owner_declares_has_api_keys
      return if owner.blank?
      return if RailsApiKeys.owner_class?(owner.class)

      errors.add(:owner, "must declare has_api_keys")
    end

    def permission_immutable
      return unless permission_changed? && persisted?

      errors.add(:permission, "cannot be changed after creation")
    end
  end
end
