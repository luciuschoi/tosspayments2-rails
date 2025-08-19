## [Unreleased]

_No changes yet._

## [0.2.0] - 2025-08-19
### Added
- WebhookVerifier HMAC (SHA256 + Base64) verification
- CallbackVerifier renamed method to `match_amount?` predicate style
- Retries with backoff for HTTP client
- Request ID extraction in APIError (header `X-Request-Id` if present)

### Changed
- Renamed `WebhookVerifier#verify` to `verify?` for predicate semantics
- Internal refactors reducing controller template complexity
- Moved development dependencies out of gemspec into Gemfile
- Style/lint cleanup (RuboCop baseline now clean)

### Fixed
- Ensured secure constant-time comparison implementation naming clarity

## [0.1.0] - 2025-08-19

- Initial release
