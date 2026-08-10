# frozen_string_literal: true

RSpec.describe RailsApiKeys::Configuration do
  subject(:config) { described_class.new }

  describe "#resolved_token_prefix" do
    it "defaults to the host application name" do
      expect(config.resolved_token_prefix).to eq("dummy_ak_")
    end

    it "uses an explicit token_prefix when set" do
      config.token_prefix = "hris_ak_"

      expect(config.resolved_token_prefix).to eq("hris_ak_")
    end
  end

  describe "#owner_class_name" do
    it "stringifies owner_class" do
      config.owner_class = User

      expect(config.owner_class_name).to eq("User")
    end
  end

  describe "#owner_active?" do
    it "delegates to active_for_authentication? when available" do
      owner = User.create!(email: "a@example.com", active: true)
      inactive = User.create!(email: "b@example.com", active: false)

      expect(config.owner_active?(owner)).to be(true)
      expect(config.owner_active?(inactive)).to be(false)
    end

    it "returns true when the owner has no active_for_authentication?" do
      owner = Object.new

      expect(config.owner_active?(owner)).to be(true)
    end

    it "uses a custom owner_active proc" do
      config.owner_active = ->(_owner) { false }
      owner = User.create!(email: "c@example.com", active: true)

      expect(config.owner_active?(owner)).to be(false)
    end
  end
end
