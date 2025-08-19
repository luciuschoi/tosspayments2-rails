# frozen_string_literal: true

class PaymentsController < ApplicationController
  include Tosspayments2::Rails::ControllerConcern

  def success
    load_params
    verify_amount!
    @payment = toss_client.confirm(payment_key: @payment_key, order_id: @order_id, amount: @amount)
  rescue Tosspayments2::Rails::VerificationError, Tosspayments2::Rails::APIError => e
    Rails.logger.error("Payment error: #{e.class} #{e.message}")
    redirect_to root_path, alert: '결제 승인 실패'
  end

  def fail
    flash[:alert] = "결제 실패: #{params[:message] || params[:errorMessage]}"
    redirect_to root_path
  end

  private

  def load_params
    @payment_key = params[:paymentKey]
    @order_id    = params[:orderId]
    @amount      = params[:amount].to_i
  end

  def verify_amount!
    Tosspayments2::Rails::CallbackVerifier.new.match_amount?(order_id: @order_id, amount: @amount) do |_oid|
      # Lookup the expected amount for the given order id in your domain model.
      # Example:
      #   Order.find_by!(uuid: _oid).amount
      # For demo purposes we return a fixed integer:
      1000
    end
  end
end
