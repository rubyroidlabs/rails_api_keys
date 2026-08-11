# frozen_string_literal: true

RSpec.describe RailsApiKeys::Owner do
  describe ".has_api_keys" do
    it "registers User and Company as owners with an api_keys association" do
      expect(RailsApiKeys.owner_class?(User)).to be(true)
      expect(RailsApiKeys.owner_class?(Company)).to be(true)
      expect(User.reflect_on_association(:api_keys).class_name).to eq("RailsApiKeys::ApiKey")
      expect(Company.reflect_on_association(:api_keys).class_name).to eq("RailsApiKeys::ApiKey")
    end

    it "does not register Organization" do
      expect(RailsApiKeys.owner_class?(Organization)).to be(false)
      expect(Organization.reflect_on_association(:api_keys)).to be_nil
    end

    it "adds create_api_key! on User" do
      user = User.create!(email: "owner@example.com", active: true)

      key, raw = user.create_api_key!(name: "Zapier", permission: :read)

      expect(key).to be_persisted
      expect(key.owner).to eq(user)
      expect(raw).to be_present
    end

    it "adds create_api_key! on Company" do
      company = Company.create!(name: "Acme")

      key, raw = company.create_api_key!(name: "Billing", permission: :read_write)

      expect(key).to be_persisted
      expect(key.owner).to eq(company)
      expect(raw).to be_present
    end

    it "does not add create_api_key! on Organization" do
      expect(Organization.instance_methods).not_to include(:create_api_key!)
    end
  end
end
