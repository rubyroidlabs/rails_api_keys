# rails_api_keys

[![CI](https://github.com/rubyroidlabs/rails_api_keys/actions/workflows/ci.yml/badge.svg)](https://github.com/rubyroidlabs/rails_api_keys/actions/workflows/ci.yml)

Reusable Rails engine for personal API keys: create (reveal once), hash at rest, revoke, and authenticate via `Authorization: Bearer <token>`.

Host apps own UI, routes, and domain APIs. This gem stays thin on purpose.

## What this gem includes

- `RailsApiKeys::ApiKey` — issue, authenticate, revoke
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

Until the gem is published on RubyGems, you can use git or a local path:

```ruby
gem "rails_api_keys", git: "https://github.com/rubyroidlabs/rails_api_keys.git"
# or: gem "rails_api_keys", path: "../rails_api_keys"
```

## Host setup

On the owner model (defaults to `User`):

```ruby
class User < ApplicationRecord
  has_many :api_keys, as: :owner, class_name: "RailsApiKeys::ApiKey", dependent: :destroy
end
```

Build your own controllers/UI to create keys (show the raw token once), list them, and revoke.

## Configuration

Defaults suit a typical Devise `User` host:

| Option | Default | Purpose |
| --- | --- | --- |
| `owner_class` | `"User"` | Expected owner class name |
| `token_prefix` | `"#{AppName.downcase}_ak_"` | Prefix on generated raw tokens |
| `owner_active` | `active_for_authentication?` when present | Reject keys whose owner is inactive |

Override only what you need:

```ruby
# config/initializers/rails_api_keys.rb
RailsApiKeys.configure do |config|
  # config.token_prefix = "myapp_ak_"
  # config.owner_class = "Admin"
  # config.owner_active = ->(owner) { owner.active? }
end
```

## Usage

```ruby
key, raw = RailsApiKeys::ApiKey.generate_for!(
  owner: current_user,
  name: "Zapier",
  permission: :read
)
# Show `raw` once — it cannot be recovered later.

RailsApiKeys::ApiKey.authenticate(raw) # => key or nil
key.revoke!
```

```ruby
class Api::V1::BaseController < ActionController::API
  include RailsApiKeys::Authentication

  before_action :authenticate_api_key!
  before_action -> { require_api_permission!(:read) }

  # current_api_key / current_api_owner are available after authenticate
end
```

Clients send:

```http
Authorization: Bearer <raw_token>
```

## Permissions

| Permission | `allows_read?` | `allows_write?` |
| --- | --- | --- |
| `read` | yes | no |
| `read_write` | yes | yes |

Permissions are immutable after create. Revoke with `revoke!` (sets `revoked_at`).

## Security notes

- Raw tokens are returned only from `generate_for!` and never stored
- Digests use SHA-256 (`token_digest`); UI can show `token_display_prefix`
- Soft revoke via `revoked_at`; authentication ignores revoked keys

## Development

```bash
bundle install
bundle exec rspec
bin/rubocop
```

See [CHANGELOG.md](./CHANGELOG.md) for release notes. Agent-oriented notes live in [`AGENTS.md`](./AGENTS.md).

## License

This project is licensed under the [MIT License](./LICENSE).

---

<p align="center">
  <a href="https://rubyroidlabs.com">
    <img src="./docs/logo.svg" alt="Rubyroid Labs" width="220" />
  </a>
</p>

**[Rubyroid Labs](https://rubyroidlabs.com)** — full-cycle software development company for businesses delivering scalable web and mobile apps, dedicated developers, and full-cycle teams in Ruby on Rails, React Native, and UX/UI. 98% on-time delivery.

- Website: [rubyroidlabs.com](https://rubyroidlabs.com)
- Email: [hi@rubyroidlabs.com](mailto:hi@rubyroidlabs.com)
- References: [Clutch](https://clutch.co/profile/rubyroid-labs)
