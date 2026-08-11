# rails_api_keys

[![CI](https://github.com/rubyroidlabs/rails_api_keys/actions/workflows/ci.yml/badge.svg)](https://github.com/rubyroidlabs/rails_api_keys/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/rails_api_keys.svg?icon=si%3Arubygems&icon_color=%23ee3f2d)](https://badge.fury.io/rb/rails_api_keys)

Reusable Rails engine for personal API keys: create (reveal once), hash at rest, revoke, and authenticate via `Authorization: Bearer <token>`.

Host apps own UI, routes, and domain APIs. This gem stays thin on purpose.

## What this gem includes

- `RailsApiKeys::ApiKey` — issue, authenticate, revoke
- `has_api_keys` — opt-in owner macro with `create_api_key!` (supports multiple models)
- `RailsApiKeys::Authentication` — controller concern for Bearer tokens
- Install generator (migration + initializer)

No mailers, jobs, views, assets, or mounted domain routes.

## Installation

Add the gem and install:

```ruby
# Gemfile
gem "rails_api_keys"
```

```bash
bundle install
bin/rails generate rails_api_keys:install
bin/rails db:migrate
```

## Host setup

Opt in on each owner model with `has_api_keys` (any number of models):

```ruby
class User < ApplicationRecord
  has_api_keys
end

class Company < ApplicationRecord
  has_api_keys
end
```

That declares `has_many :api_keys` and allows the model to own keys. Build your own controllers/UI to create keys (show the raw token once), list them, and revoke.

## Configuration

Defaults suit a typical Devise `User` host; multiple owners are supported via `has_api_keys`:

| Option | Default | Purpose |
| --- | --- | --- |
| `token_prefix` | `"#{AppName.downcase}_ak_"` | Prefix on generated raw tokens |
| `owner_active` | `active_for_authentication?` when present | Reject keys whose owner is inactive |

Override only what you need:

```ruby
# config/initializers/rails_api_keys.rb
RailsApiKeys.configure do |config|
  # config.token_prefix = "myapp_ak_"
  # config.owner_active = ->(owner) { owner.active? }
end
```

## Usage

```ruby
key, raw = current_user.create_api_key!(name: "Zapier", permission: :read)
# Show `raw` once — it cannot be recovered later.

RailsApiKeys::ApiKey.authenticate(raw) # => key or nil
key.revoke!
```

```ruby
class Api::V1::BaseController < ActionController::API
  include RailsApiKeys::Authentication

  before_action :authenticate_api_key!

  # current_api_key / current_api_owner are available after authenticate
end
```

Clients send:

```http
Authorization: Bearer <raw_token>
```

`authenticate_api_key!` rejects missing/invalid tokens with 401, then enforces permission from the HTTP method: GET/HEAD require read; other methods require write (403 if the key lacks it).

## Permissions

| Permission | GET/HEAD | Other methods |
| --- | --- | --- |
| `read` | allowed | forbidden |
| `read_write` | allowed | allowed |

Permissions are immutable after create. Revoke with `revoke!` (sets `revoked_at`).

## Security notes

- Raw tokens are returned only from `create_api_key!` / `generate_for!` and never stored
- Digests use SHA-256 (`token_digest`); UI can show `token_display_prefix`
- Soft revoke via `revoked_at`; authentication ignores revoked keys

## Development

```bash
bundle install
bundle exec rspec
bin/rubocop
```

See [CHANGELOG.md](./CHANGELOG.md) for release notes. Agent-oriented notes live in [`AGENTS.md`](./AGENTS.md).

## Contributing

Bug reports and pull requests are welcome. See [CONTRIBUTING.md](./CONTRIBUTING.md) and the [Code of Conduct](./CODE_OF_CONDUCT.md).

To report a security vulnerability privately, see [SECURITY.md](./SECURITY.md).

## License

This project is licensed under the [MIT License](./LICENSE).

---

<p align="center">
  <a href="https://rubyroidlabs.com">
    <img src="./docs/logo.svg" alt="Rubyroid Labs" width="100%" />
  </a>
</p>

**[Rubyroid Labs](https://rubyroidlabs.com)** — full-cycle software development company for businesses delivering scalable web and mobile apps, dedicated developers, and full-cycle teams in Ruby on Rails, React Native, and UX/UI. 98% on-time delivery.

- Website: [rubyroidlabs.com](https://rubyroidlabs.com)
- Email: [hi@rubyroidlabs.com](mailto:hi@rubyroidlabs.com)
- References: [Clutch](https://clutch.co/profile/rubyroid-labs)
