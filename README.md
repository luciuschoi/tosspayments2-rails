# tosspayments2-rails

Rails 7 & 8용 TossPayments v2 (통합 SDK / 결제위젯) 간편 연동 지원 젬.

* View helper (`tosspayments_script_tag`) 로 SDK `<script>` 주입
* 환경설정 (`Tosspayments2::Rails.configure`) 으로 client/secret 키 관리
* 서버사이드 결제 승인(confirm) & 취소(cancel) API 래퍼 `Tosspayments2::Rails::Client`
* Controller concern (`Tosspayments2::Rails::ControllerConcern`) 으로 `toss_client` 제공
* (Placeholder) Webhook 검증 클래스 (향후 사양 반영 예정)

## 설치 (Installation)

Gemfile:
```ruby
gem 'tosspayments2-rails'
```
설치 후:
```bash
bundle install
```

아직 Rubygems 공개 전이라면 Git 소스 사용:
```ruby
gem 'tosspayments2-rails', git: 'https://github.com/luciuschoi/tosspayments2-rails'
```

## 초기 설정 (Configuration)
`config/initializers/tosspayments2.rb` 생성:
```ruby
Tosspayments2::Rails.configure do |c|
	c.client_key = ENV.fetch('TOSSPAYMENTS_CLIENT_KEY')
	c.secret_key = ENV.fetch('TOSSPAYMENTS_SECRET_KEY')
	# c.widget_version = 'v2' # 기본값
	# c.api_base = 'https://api.tosspayments.com' # 기본값
end
```

또는 `config/application.rb` 등에서:
```ruby
config.tosspayments2.client_key = ENV['TOSSPAYMENTS_CLIENT_KEY']
config.tosspayments2.secret_key = ENV['TOSSPAYMENTS_SECRET_KEY']
```

## View에서 SDK 스크립트 추가
레이아웃 (`app/views/layouts/application.html.erb`):
```erb
<head>
	<%= csrf_meta_tags %>
	<%= csp_meta_tag %>
	<%= tosspayments_script_tag %>
</head>
```

커스텀 버전/옵션:
```erb
<%= tosspayments_script_tag(async: true, defer: true, version: 'v2') %>
```

## 프론트엔드 예시 (Stimulus / ES module 없이 단순)
```erb
<div id="payment-methods"></div>
<div id="agreement"></div>
<button id="pay">결제하기</button>
<script>
	document.addEventListener('DOMContentLoaded', async () => {
		const clientKey = '<%= ENV['TOSSPAYMENTS_CLIENT_KEY'] %>';
		const customerKey = 'customer_123'; // 구매자 식별 값
		const tosspayments = TossPayments(clientKey);
		const widgets = tosspayments.widgets({ customerKey });
		await widgets.setAmount({ value: 10000, currency: 'KRW' });
		await widgets.renderPaymentMethods({ selector: '#payment-methods' });
		await widgets.renderAgreement({ selector: '#agreement' });

		document.getElementById('pay').addEventListener('click', async () => {
			try {
				await widgets.requestPayment({
					orderId: 'ORDER-' + Date.now(),
					orderName: '테스트 주문',
					customerName: '홍길동',
					successUrl: '<%= success_payments_url %>',
					failUrl: '<%= fail_payments_url %>'
				});
			} catch (e) {
				console.error(e);
			}
		});
	});
 </script>
```

## 성공/실패 리다이렉트 컨트롤러 예시
```ruby
class PaymentsController < ApplicationController
	include Tosspayments2::Rails::ControllerConcern

	def success
		# TossPayments에서 쿼리로 전달: paymentKey, orderId, amount
		payment_key = params[:paymentKey]
		order_id = params[:orderId]
		amount = params[:amount].to_i
		result = toss_client.confirm(payment_key: payment_key, order_id: order_id, amount: amount)
		# 비즈니스 로직 (주문 상태 업데이트 등)
		@payment = result
	rescue Tosspayments2::Rails::Client::HTTPError => e
		logger.error("Toss confirm error: #{e.response.inspect}")
		redirect_to root_path, alert: '결제 승인 실패'
	end

	def fail
		# errorCode, errorMessage 등 전달
		flash[:alert] = "결제 실패: #{params[:message] || params[:errorMessage]}"
		redirect_to root_path
	end
end
```

라우팅 (`config/routes.rb`):
```ruby
resource :payments, only: [] do
	get :success
	get :fail
end
```

## 서버사이드 결제 취소
```ruby
toss_client.cancel(payment_key: payment.payment_key, cancel_reason: '고객요청')
```

## RBS (타입 시그니처)
`sig/` 디렉토리에 기본 시그니처가 포함되어 있습니다. 필요 시 확장하세요.

## 테스트 / 개발
```bash
bin/console
```
```ruby
Tosspayments2::Rails.configure { |c| c.secret_key = 'sk_test_xxx' }
client = Tosspayments2::Rails::Client.new(secret_key: 'sk_test_xxx')
# Stub 네트워크 후 confirm 호출 등
```

## 라이선스
MIT

## 기여
PR / 이슈 환영: https://github.com/luciuschoi/tosspayments2-rails
