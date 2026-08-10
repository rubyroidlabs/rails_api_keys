# frozen_string_literal: true

require_relative "lib/rails_api_keys/version"

Gem::Specification.new do |spec|
  spec.name        = "rails_api_keys"
  spec.version     = RailsApiKeys::VERSION
  spec.authors     = [ "Pavel Pershko" ]
  spec.email       = [ "pavel.pershko@rubyroidlabs.com" ]
  spec.summary     = "Reusable Rails engine for personal API key authentication."
  spec.description = "Issue, hash, revoke, and authenticate personal API keys with read/read_write permissions."

  # Private gem — block accidental pushes to rubygems.org
  spec.metadata["allowed_push_host"] = "https://example.invalid"

  spec.files = Dir.chdir(__dir__) do
    Dir["{app,config,db,lib}/**/*", "Rakefile", "README.md", "AGENTS.md"].select { |f| File.file?(f) }
  end

  spec.required_ruby_version = ">= 3.2.0"
  spec.add_dependency "rails", ">= 7.0"
end
