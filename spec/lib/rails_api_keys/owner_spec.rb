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
  end
end
