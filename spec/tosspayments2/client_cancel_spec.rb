# frozen_string_literal: true

require 'spec_helper'
require 'webmock/rspec'

RSpec.describe Tosspayments2::Rails::Client do
  let(:secret) { 'sk_test_x' }
  let(:client) { described_class.new(secret_key: secret, api_base: 'https://api.tosspayments.com') }

  before do
    stub_request(:post, 'https://api.tosspayments.com/v1/payments/confirm')
  end

  describe '#cancel' do
    it 'cancels successfully (full cancel)' do
      cancel_body = { paymentKey: 'pay_123', status: 'CANCELED' }
      stub = stub_request(:post, 'https://api.tosspayments.com/v1/payments/pay_123/cancel')
      stub.to_return(status: 200, body: cancel_body.to_json, headers: { 'Content-Type' => 'application/json' })
      response = client.cancel(payment_key: 'pay_123', cancel_reason: 'test')
      expect(response[:status]).to eq('CANCELED')
      expect(stub).to have_been_requested
    end

    it 'raises APIError on failure' do
      error_body = { code: 'INVALID', message: 'bad' }
      stub = stub_request(:post, 'https://api.tosspayments.com/v1/payments/pay_456/cancel')
      stub.to_return(status: 400, body: error_body.to_json, headers: { 'Content-Type' => 'application/json' })
      expect { client.cancel(payment_key: 'pay_456', cancel_reason: 'test') }
        .to raise_error(Tosspayments2::Rails::APIError) { |e| expect(e.body[:code]).to eq('INVALID') }
      expect(stub).to have_been_requested
    end
  end
end
