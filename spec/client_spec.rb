# frozen_string_literal: true

require 'spec_helper'
require 'webmock/rspec'

RSpec.describe Tosspayments2::Rails::Client do
  before do
    Tosspayments2::Rails.configure do |c|
      c.secret_key = 'sk_test_123'
    end
  end

  let(:client) { described_class.new }

  it 'raises ConfigurationError without secret key' do
    Tosspayments2::Rails.configure { |c| c.secret_key = nil }
    expect { described_class.new }.to raise_error(Tosspayments2::Rails::ConfigurationError)
  end

  it 'performs confirm success' do
    body_hash = { paymentKey: 'pk', orderId: 'o1', status: 'DONE' }
    stub = stub_request(:post, 'https://api.tosspayments.com/v1/payments/confirm')
    stub.to_return(status: 200, body: body_hash.to_json, headers: { 'Content-Type' => 'application/json' })
    response = client.confirm(payment_key: 'pk', order_id: 'o1', amount: 1000)
    expect(response[:status]).to eq('DONE')
    expect(stub).to have_been_requested
  end

  it 'raises APIError on failure' do
    stub_request(:post, 'https://api.tosspayments.com/v1/payments/confirm').to_return(
      status: 400,
      body: { code: 'INVALID', message: 'Bad' }.to_json,
      headers: { 'Content-Type' => 'application/json' }
    )
    expect { client.confirm(payment_key: 'pk', order_id: 'o1', amount: 1000) }
      .to raise_error(Tosspayments2::Rails::APIError) { |e| expect(e.code).to eq('INVALID') }
  end
end
