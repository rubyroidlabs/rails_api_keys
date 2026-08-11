# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0/).

## [Unreleased]

## [0.2.0] - 2026-08-10

### Added

- `has_api_keys` — Active Record macro for owner models (`User`, `Company`, etc.); registers allowed polymorphic owners

### Changed

- `authenticate_api_key!` now enforces permissions from the HTTP method: GET/HEAD require read; other methods require write

### Removed

- `require_api_permission!` — hosts no longer call this separately
- `config.owner_class` — replaced by opt-in `has_api_keys` on each owner model

## [0.1.0] - 2026-08-10

### Added

- `RailsApiKeys::ApiKey` — create (raw token once), SHA-256 digest storage, soft revoke, `read` / `read_write` permissions
- `RailsApiKeys::Authentication` — Bearer token auth helpers for `ActionController::API`
- `RailsApiKeys.configure` — optional `owner_class`, `token_prefix`, and `owner_active`
- Install generator (`rails_api_keys:install`) for migration and initializer

[Unreleased]: https://github.com/rubyroidlabs/rails_api_keys/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/rubyroidlabs/rails_api_keys/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/rubyroidlabs/rails_api_keys/releases/tag/v0.1.0
