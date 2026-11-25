# frozen_string_literal: true

require "ipaddr"

module RailsApiKeys
  # Normalizes, validates, and matches IPv4/IPv6 addresses and CIDR ranges.
  class IpAllowlist
    attr_reader :entries

    def initialize(raw_entries)
      @entries = normalize(raw_entries)
    end

    def invalid_entries
      entries.reject { |entry| valid_entry?(entry) }
    end

    def valid?
      invalid_entries.empty?
    end

    def allows?(ip)
      return true if entries.empty?
      return false if ip.blank?

      candidate = parse_candidate(ip)
      return false unless candidate

      entries.any? { |entry| matches_entry?(entry, candidate) }
    end

    private

    def normalize(value)
      raw =
        case value
        when nil
          []
        when String
          value.split(/[\r\n,]+/)
        when Array
          value
        else
          [ value ]
        end

      raw.filter_map { |entry| entry.to_s.strip.presence }.uniq
    end

    def valid_entry?(entry)
      IPAddr.new(entry.to_s)
      true
    rescue IPAddr::InvalidAddressError, IPAddr::InvalidPrefixError
      false
    end

    def parse_candidate(ip)
      candidate = IPAddr.new(ip.to_s)
      candidate.ipv4_mapped? ? candidate.native : candidate
    rescue IPAddr::InvalidAddressError, IPAddr::InvalidPrefixError
      nil
    end

    def matches_entry?(entry, candidate)
      IPAddr.new(entry).include?(candidate)
    rescue IPAddr::InvalidAddressError, IPAddr::InvalidPrefixError
      false
    end
  end
end
