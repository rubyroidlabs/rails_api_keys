# rails_api_keys — Agent Guide

Thin, reusable Rails engine for personal API keys. Host apps own UI, routes, and domain APIs.

## Stack

- Ruby gem / Rails engine (`isolate_namespace RailsApiKeys`)
- Active Record model + install generator
- Auth concern for `ActionController::API` (Bearer token)

## Naming

Gem, require, and repo all use **`rails_api_keys`**. Module is `RailsApiKeys`.

```ruby
gem "rails_api_keys", git: "…" # or path:
```

No custom `require:` needed.

## Architecture (keep it thin)

**In this gem**

- `RailsApiKeys::ApiKey` — create (return raw once), SHA-256 digest, soft revoke, `read` / `read_write`
- `RailsApiKeys::Authentication` — `authenticate_api_key!` (Bearer + method-based permission), `current_api_key` / `current_api_owner`
- `RailsApiKeys.configure` — optional overrides (`owner_class`, `token_prefix`, `owner_active`)
- Install generator (migration + initializer)

**Not in this gem**

- Key management UI, domain APIs, mailers, jobs, views, assets, session auth

## Critical rules

- Do **not** reintroduce unused Rails scaffolds unless a real feature needs them.
- Do **not** put host-app business endpoints in the engine.
- Raw token is returned only from `generate_for!`; never store plaintext.
- Permissions are immutable after create; revoke via soft `revoked_at`.
- Prefer single quotes; `# frozen_string_literal: true` on Ruby files.
- Run `bundle exec rspec` and `bundle exec rubocop` after non-trivial changes.

## Commands

```bash
bundle install
bundle exec rspec
bin/rubocop
```

Specs live under `spec/` and boot `spec/dummy` (sqlite).

## Where to look

- Project state: `.cursor/rules/context.mdc`
- Model: `app/models/rails_api_keys/api_key.rb`
- Auth: `lib/rails_api_keys/authentication.rb`
- Config: `lib/rails_api_keys/configuration.rb`
