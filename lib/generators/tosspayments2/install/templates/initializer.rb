# frozen_string_literal: true

# TossPayments2 configuration
Tosspayments2::Rails.configure do |c|
  # Rails credentials 우선, 없으면 환경 변수 사용
  c.client_key = Rails.application.credentials.dig(:tosspayments, :client_key) ||
                 ENV.fetch('TOSSPAYMENTS_CLIENT_KEY', nil)
  c.secret_key = Rails.application.credentials.dig(:tosspayments, :secret_key) ||
                 ENV.fetch('TOSSPAYMENTS_SECRET_KEY', nil)

  # 선택적 설정들 (기본값 사용 가능)
  # c.widget_version = 'v2'
  # c.api_base = 'https://api.tosspayments.com'
  # c.timeout = 10
end

# credentials.yml.enc 파일 설정 예시:
# $ EDITOR="nano" bin/rails credentials:edit
#
# tosspayments:
#   client_key: test_ck_D5GePWvyJnrK0W0k6q8gLzN97Eoqo56A
#   secret_key: test_sk_zXLkKEypNArWmo50nX3lmeaxYG5vSSu7
#
# 또는 환경 변수로 설정:
# export TOSSPAYMENTS_CLIENT_KEY=test_ck_D5GePWvyJnrK0W0k6q8gLzN97Eoqo56A
# export TOSSPAYMENTS_SECRET_KEY=test_sk_zXLkKEypNArWmo50nX3lmeaxYG5vSSu7
