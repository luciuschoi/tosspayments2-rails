# frozen_string_literal: true

# TossPayments2 configuration
Tosspayments2::Rails.configure do |c|
  c.client_key = ENV.fetch('TOSSPAYMENTS_CLIENT_KEY', nil)
  c.secret_key = ENV.fetch('TOSSPAYMENTS_SECRET_KEY', nil)
  # c.widget_version = 'v2'
  # c.api_base = 'https://api.tosspayments.com'
end
