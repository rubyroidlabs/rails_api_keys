# Security Policy

## Supported versions

Security fixes are applied to the latest released version of `rails_api_keys`. Please upgrade before reporting issues that may already be fixed.

## Reporting a vulnerability

Please **do not** open a public GitHub issue for security vulnerabilities.

Prefer one of these private channels:

1. **[GitHub private vulnerability advisory](https://github.com/rubyroidlabs/rails_api_keys/security/advisories/new)** (preferred)
2. Email **[hello@rubyroidlabs.com](mailto:hello@rubyroidlabs.com)** with a clear subject such as `[rails_api_keys] Security vulnerability`

Include as much detail as you can:

- Affected gem version(s)
- Impact (e.g. auth bypass, token leakage, privilege escalation)
- Steps to reproduce or a minimal proof of concept
- Any known workarounds

We will acknowledge the report when we can, keep the discussion private until a fix is ready, and credit reporters who want acknowledgment in the advisory or changelog.

## Scope

In scope: authentication, token generation/storage, revoke behavior, and permission enforcement in this gem.

Out of scope: vulnerabilities only in a host application’s UI, routes, or session auth that are unrelated to this engine.
