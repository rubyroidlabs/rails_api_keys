# frozen_string_literal: true

RSpec.describe RailsApiKeys do
  describe ".configure" do
    it "yields and persists configuration" do
      described_class.configure do |config|
        config.token_prefix = "test_ak_"
      end

      expect(described_class.configuration.token_prefix).to eq("test_ak_")
      expect(described_class.configuration.resolved_token_prefix).to eq("test_ak_")
    end
  end

  describe ".reset_configuration!" do
    it "restores defaults" do
      described_class.configure { |c| c.token_prefix = "x_" }
      described_class.reset_configuration!

      expect(described_class.configuration.token_prefix).to be_nil
      expect(described_class.configuration.resolved_token_prefix).to eq("dummy_ak_")
    end

    it "does not clear registered owner classes" do
      expect(described_class.owner_class?(User)).to be(true)

      described_class.reset_configuration!

      expect(described_class.owner_class?(User)).to be(true)
      expect(described_class.owner_class?(Company)).to be(true)
    end
  end
end
