# frozen_string_literal: true

class PaymentsController < ApplicationController
  include Tosspayments2::Rails::ControllerConcern

  before_action :set_payment, only: %i[show cancel]

  def index
    @payments = Payment.order(created_at: :desc)
  end

  def show; end

  def new
    @payment = Payment.new
    @order_id = "ORDER-#{Time.current.strftime('%Y%m%d%H%M%S')}-#{SecureRandom.hex(4)}"
  end

  def create
    @payment = Payment.new(payment_params)
    @payment.status = 'pending'
    @payment.order_id = "ORDER-#{Time.current.strftime('%Y%m%d%H%M%S')}-#{SecureRandom.hex(4)}"

    if @payment.save
      redirect_to checkout_payments_path(order_id: @payment.order_id)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def checkout
    @order_id = params[:order_id]
    @payment = Payment.find_by!(order_id: @order_id)
  end

  def success
    load_params
    verify_amount!
    process_payment_confirmation
    redirect_to @payment, notice: '결제가 성공적으로 완료되었습니다.'
  rescue Tosspayments2::Rails::VerificationError, Tosspayments2::Rails::APIError => e
    handle_payment_error(e)
  end

  def fail
    order_id = params[:orderId]

    # 실패 시 Payment 상태 업데이트
    if order_id && (payment = Payment.find_by(order_id: order_id))
      payment.update(status: 'failed')
    end

    flash[:alert] = "결제 실패: #{params[:message] || params[:errorMessage]}"
    redirect_to root_path
  end

  def cancel
    toss_client.cancel(
      payment_key: @payment.transaction_id,
      cancel_reason: params[:cancel_reason] || '고객 요청에 의한 취소'
    )
    @payment.update!(status: 'cancelled')
    redirect_to @payment, notice: '결제가 취소되었습니다.'
  rescue Tosspayments2::Rails::APIError => e
    Rails.logger.error("Payment cancel error: #{e.message}")
    redirect_to @payment, alert: '결제 취소에 실패했습니다.'
  end

  private

  def set_payment
    @payment = Payment.find_by(id: params[:id])
    return if @payment

    redirect_to payments_path, alert: '결제 정보를 찾을 수 없습니다.'
  end

  def payment_params
    params.require(:payment).permit(:amount)
  end

  def load_params
    @payment_key = params[:paymentKey]
    @order_id    = params[:orderId]
    @amount      = params[:amount].to_i
  end

  def verify_amount!
    Tosspayments2::Rails::CallbackVerifier.new.match_amount?(order_id: @order_id, amount: @amount) do |oid|
      # 저장된 Payment 레코드에서 금액 확인
      payment = Payment.find_by(order_id: oid)
      payment&.amount || 0
    end
  end

  def process_payment_confirmation
    # 결제 승인 API 호출
    toss_response = toss_client.confirm(payment_key: @payment_key, order_id: @order_id, amount: @amount)

    # Payment 레코드 생성 또는 업데이트
    @payment = find_or_create_payment

    # 결제 승인 성공 시 상태 업데이트
    @payment.update!(
      status: 'confirmed',
      transaction_id: toss_response[:paymentKey] || toss_response['paymentKey']
    )
  end

  def find_or_create_payment
    Payment.find_or_create_by(order_id: @order_id) do |payment|
      payment.amount = @amount
      payment.status = 'pending'
    end
  end

  def handle_payment_error(error)
    Rails.logger.error("Payment error: #{error.class} #{error.message}")

    # 실패 시 Payment 상태 업데이트
    update_payment_status_on_failure

    redirect_to root_path, alert: '결제 승인에 실패했습니다.'
  end

  def update_payment_status_on_failure
    return unless @order_id

    payment = Payment.find_by(order_id: @order_id)
    payment&.update(status: 'failed')
  end
end
