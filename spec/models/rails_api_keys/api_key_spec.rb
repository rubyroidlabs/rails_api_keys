# frozen_string_literal: true

RSpec.describe RailsApiKeys::ApiKey, type: :model do
  let(:user) { User.create!(email: "manager@example.com") }
  let(:company) { Company.create!(name: "Acme Corp") }

  describe ".generate_for!" do
    it "creates a key and returns the raw token once" do
      record, raw = described_class.generate_for!(owner: user, name: "Zapier", permission: :read)

      expect(record).to be_persisted
      expect(record.name).to eq("Zapier")
      expect(record).to be_read
      expect(record.token_digest).to eq(described_class.digest(raw))
      expect(record.token_display_prefix).to eq(raw[0, described_class::DISPLAY_PREFIX_LENGTH])
      expect(raw).to start_with("dummy_ak_")
      expect(record.attributes.values).not_to include(raw)
    end

    it "creates a key for a Company owner" do
      record, raw = described_class.generate_for!(owner: company, name: "Billing", permission: :read_write)

      expect(record).to be_persisted
      expect(record.owner).to eq(company)
      expect(record).to be_read_write
      expect(described_class.authenticate(raw)).to eq(record)
    end

    it "uses a custom token_prefix when configured" do
      RailsApiKeys.configure { |c| c.token_prefix = "custom_ak_" }

      _record, raw = described_class.generate_for!(owner: user, name: "Custom", permission: :read)

      expect(raw).to start_with("custom_ak_")
    end

    it "rejects owners that do not declare has_api_keys" do
      organization = Organization.create!(name: "Acme")

      expect {
        described_class.generate_for!(owner: organization, name: "Bad", permission: :read)
      }.to raise_error(ActiveRecord::RecordInvalid, /Owner must declare has_api_keys/)
    end
  end

  describe ".authenticate" do
    let!(:pair) { described_class.generate_for!(owner: user, name: "Auth", permission: :read_write) }
    let(:key) { pair.first }
    let(:raw) { pair.last }

    it "returns the key for a valid token and updates last_used_at" do
      expect(key.last_used_at).to be_nil

      authenticated = described_class.authenticate(raw)

      expect(authenticated).to eq(key)
      expect(authenticated.reload.last_used_at).to be_present
    end

    it "returns nil for a blank token" do
      expect(described_class.authenticate(nil)).to be_nil
      expect(described_class.authenticate("")).to be_nil
    end

    it "returns nil for an unknown token" do
      expect(described_class.authenticate("dummy_ak_not-a-real-token")).to be_nil
    end

    it "returns nil for a revoked key" do
      key.revoke!

      expect(described_class.authenticate(raw)).to be_nil
    end

    it "returns nil when the owner is inactive" do
      user.update!(active: false)

      expect(described_class.authenticate(raw)).to be_nil
    end
  end

  describe "#revoke!" do
    it "soft-revokes the key" do
      key, = described_class.generate_for!(owner: user, name: "Revoke me", permission: :read)

      key.revoke!

      expect(key).to be_revoked
      expect(key).not_to be_active
      expect(described_class.active).not_to include(key)
    end
  end

  describe "permissions" do
    it "treats read keys as read-only" do
      key, = described_class.generate_for!(owner: user, name: "Read", permission: :read)

      expect(key.allows_read?).to be(true)
      expect(key.allows_write?).to be(false)
    end

    it "treats read_write keys as readable and writable" do
      key, = described_class.generate_for!(owner: user, name: "RW", permission: :read_write)

      expect(key.allows_read?).to be(true)
      expect(key.allows_write?).to be(true)
    end

    it "does not allow changing permission after create" do
      key, = described_class.generate_for!(owner: user, name: "Locked", permission: :read)

      key.permission = :read_write

      expect(key).not_to be_valid
      expect(key.errors[:permission]).to include("cannot be changed after creation")
    end
  end
end
