# rails_api_keys

Reusable Rails engine for personal API keys: create (reveal once), hash at rest, revoke, and authenticate via `Authorization: Bearer <token>`.

Agent docs: [`AGENTS.md`](./AGENTS.md), Cursor context: [`.cursor/rules/context.mdc`](./.cursor/rules/context.mdc).

## What this gem includes

- `RailsApiKeys::ApiKey` model
- `RailsApiKeys::Authentication` concern
- Install generator (migration + initializer)

No mailers, jobs, views, assets, or mounted domain routes — host apps own those.

## Installation

```ruby
gem "rails_api_keys", git: "https://github.com/rubyroidlabs/rails_api_keys.git"
# or path: "../rails_api_keys"
```

```bash
bundle install
bin/rails generate rails_api_keys:install
bin/rails db:migrate
```

## Configuration

Defaults are enough for a typical Devise `User` host:

- `owner_class` → `"User"`
- `token_prefix` → `"#{AppName.downcase}_ak_"`
- `owner_active` → `owner.active_for_authentication?` when available

Override only what you need:

```ruby
# config/initializers/rails_api_keys.rb
RailsApiKeys.configure do |config|
  # config.token_prefix = "myapp_ak_"
  # config.owner_class = "Admin"
end
```

## Usage

```ruby
key, raw = RailsApiKeys::ApiKey.generate_for!(owner: current_user, name: "Zapier", permission: :read)
# show `raw` once — it cannot be recovered later

RailsApiKeys::ApiKey.authenticate(raw) # => key or nil
key.revoke!
```

```ruby
class Api::V1::BaseController < ActionController::API
  include RailsApiKeys::Authentication

  before_action :authenticate_api_key!
  before_action -> { require_api_permission!(:read) }
end
```

## Permissions

- `read` — read endpoints
- `read_write` — read and write (`allows_read?` is true for both)

## Development

```bash
bundle install
bundle exec rspec
```
