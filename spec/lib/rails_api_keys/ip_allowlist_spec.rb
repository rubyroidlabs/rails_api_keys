# frozen_string_literal: true

RSpec.describe RailsApiKeys::IpAllowlist do
  describe "#entries" do
    it "returns an empty array for nil or blank strings" do
      expect(described_class.new(nil).entries).to eq([])
      expect(described_class.new("  \n , ").entries).to eq([])
    end

    it "splits comma and newline separated strings, trims, and deduplicates" do
      allowlist = described_class.new(" 203.0.113.10, 10.0.0.0/24\r\n203.0.113.10\n ")

      expect(allowlist.entries).to eq([ "203.0.113.10", "10.0.0.0/24" ])
    end

    it "normalizes arrays" do
      allowlist = described_class.new([ " 203.0.113.10 ", "", nil, "203.0.113.10" ])

      expect(allowlist.entries).to eq([ "203.0.113.10" ])
    end
  end

  describe "#invalid_entries and #valid?" do
    it "is valid for IPv4, IPv6, and CIDR ranges" do
      allowlist = described_class.new([ "203.0.113.10", "10.0.0.0/24", "2001:db8::/32" ])

      expect(allowlist).to be_valid
      expect(allowlist.invalid_entries).to eq([])
    end

    it "reports invalid entries" do
      allowlist = described_class.new([ "203.0.113.10", "999.999.999.999", "10.0.0.0/99" ])

      expect(allowlist).not_to be_valid
      expect(allowlist.invalid_entries).to eq([ "999.999.999.999", "10.0.0.0/99" ])
    end
  end

  describe "#allows?" do
    it "allows any IP when empty" do
      allowlist = described_class.new([])

      expect(allowlist.allows?("203.0.113.10")).to be(true)
      expect(allowlist.allows?(nil)).to be(true)
    end

    it "matches single IPv4, IPv4-mapped IPv6, CIDR ranges, and IPv6" do
      allowlist = described_class.new([ "203.0.113.10", "10.0.0.0/24", "2001:db8::/32" ])

      expect(allowlist.allows?("203.0.113.10")).to be(true)
      expect(allowlist.allows?("::ffff:203.0.113.10")).to be(true)
      expect(allowlist.allows?("10.0.0.42")).to be(true)
      expect(allowlist.allows?("2001:db8::1")).to be(true)
      expect(allowlist.allows?("198.51.100.5")).to be(false)
      expect(allowlist.allows?("2001:db9::1")).to be(false)
      expect(allowlist.allows?("")).to be(false)
      expect(allowlist.allows?("not-an-ip")).to be(false)
    end
  end
end
