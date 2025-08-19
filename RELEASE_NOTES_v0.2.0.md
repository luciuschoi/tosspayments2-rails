# Release 0.2.0

Tag: v0.2.0  (2025-08-19)

## Highlights
- New WebhookVerifier with HMAC-SHA256 + Base64 signature checking
- HTTP client retries with backoff & request ID extraction
- CallbackVerifier predicate rename to `match_amount?`
- Predicate rename for `WebhookVerifier#verify?`
- Clean RuboCop baseline & refactored controller template
- Development dependencies relocated from gemspec to Gemfile

## Added
- Webhook verification helper
- Retry/backoff logic in client
- Request ID extraction (`X-Request-Id`) surfaced in `APIError`

## Changed
- Method renames for predicate semantics (`match_amount?`, `verify?`)
- Reduced complexity in generator payments controller
- Style & lint conformance; added quality and release rake tasks

## Fixed
- Secure constant-time compare naming clarity
- Gem build now excludes packaged `.gem` artifacts & `pkg/`

## Upgrade Notes
- Replace any `CallbackVerifier#verify!` calls with `match_amount?`
- Replace any `WebhookVerifier#verify` calls with `verify?`
- Regenerate initializer/controller via `rails generate tosspayments2:install` if you want updated template.

```ruby
# Old
verifier.verify(body, sig)
# New
verifier.verify?(body, sig)
```

```ruby
# Old
CallbackVerifier.new.verify!(order_id: oid, amount: amt) { ... }
# New
CallbackVerifier.new.match_amount?(order_id: oid, amount: amt) { ... }
```

## Publishing Steps (for maintainer)
1. Ensure environment variable RUBYGEMS_API_KEY is configured (or `~/.gem/credentials`).
2. (Optional) Run: `bundle exec rake release:check`
3. Build: `bundle exec rake build`
4. Push gem: `gem push pkg/tosspayments2-rails-0.2.0.gem`
5. Create GitHub Release using this file as the body.

SHA: PLACEHOLDER (update with commit SHA of tag)
