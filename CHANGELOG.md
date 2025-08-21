## [Unreleased]

_No changes yet._

## [0.5.3] - 2025-08-21
### Fixed
- Complete fix for checkout.html.erb template with proper ERB syntax and error handling

## [0.5.2] - 2025-08-21
### Fixed
- Fix NoMethodError in checkout.html.erb template when @payment is nil
- Add proper nil handling and error messages for missing payment in checkout flow

## [0.5.1] - 2025-08-21
### Fixed
- Fix NoMethodError in show.html.erb template when @payment is nil
- Add proper error handling in PaymentsController#set_payment method
- Add conditional rendering and error message for missing payment records

## [0.5.0] - 2025-08-21
### Added
- Complete PaymentsController with full CRUD operations (index, show, new, create, checkout, success, fail, cancel)
- Enhanced Payment model with validations, scopes, and helper methods
- New view templates: new.html.erb, checkout.html.erb with TossPayments v2 widget integration
- PaymentsHelper with status and currency formatting utilities
- Improved route configuration with collection and member routes
- Rails credentials support in initializer (fallback to environment variables)
- Comprehensive checkout flow with actual TossPayments widget implementation

### Changed
- Updated Rails migration version from 6.0 to 7.0 for Rails 7/8 compatibility
- Enhanced generator to create complete payment system structure
- Improved view templates with better styling and user experience
- Refactored PaymentsController to reduce complexity and improve maintainability
- Enhanced error handling and payment status management

### Fixed
- RuboCop violations in generated templates
- Missing routes for payment workflow
- Incomplete payment flow implementation

## [0.4.0] - 2025-08-20
### Changed
- Add frozen_string_literal magic comments to generator templates
- Update .gitignore to ignore built gem artifacts (*.gem)
- RuboCop clean; RSpec green

## [0.3.0] - 2025-08-21
### Changed
- General maintenance and improvements for release process

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
