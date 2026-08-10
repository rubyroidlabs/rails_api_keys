# frozen_string_literal: true

require_relative "lib/rails_api_keys/version"

Gem::Specification.new do |spec|
  spec.name        = "rails_api_keys"
  spec.version     = RailsApiKeys::VERSION
  spec.authors     = [ "Pavel Pershko" ]
  spec.email       = [ "pavel.pershko@rubyroidlabs.com" ]
  spec.homepage    = "https://github.com/rubyroidlabs/rails_api_keys"
  spec.summary     = "Reusable Rails engine for personal API key authentication."
  spec.description = <<~DESC
    Thin Rails engine for personal API keys: issue a raw token once, store a
    SHA-256 digest, soft-revoke, and authenticate ActionController::API
    requests with Authorization: Bearer. Host apps own UI, routes, and domain APIs.
  DESC
  spec.license = "MIT"

  spec.metadata = {
    "homepage_uri" => spec.homepage,
    "source_code_uri" => "#{spec.homepage}/tree/v#{spec.version}",
    "changelog_uri" => "#{spec.homepage}/blob/v#{spec.version}/CHANGELOG.md",
    "bug_tracker_uri" => "#{spec.homepage}/issues",
    "documentation_uri" => "https://www.rubydoc.info/gems/rails_api_keys/#{spec.version}",
    "rubygems_mfa_required" => "true",
    "allowed_push_host" => "https://rubygems.org"
  }

  spec.files = Dir.chdir(__dir__) do
    Dir[
      "{app,config,db,lib}/**/*",
      "CHANGELOG.md",
      "LICENSE",
      "README.md"
    ].select { |f| File.file?(f) }
  end
  spec.extra_rdoc_files = [ "README.md", "CHANGELOG.md", "LICENSE" ]
  spec.require_paths = [ "lib" ]

  spec.required_ruby_version = ">= 3.2.0"
  spec.add_dependency "rails", ">= 7.0"
end
