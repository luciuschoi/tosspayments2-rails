# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Tosspayments2::Rails::WebhookVerifier do
  let(:secret) { 'sk_test_webhook' }
  let(:body) { '{"event":"payment.approved","data":{"id":"123"}}' }
  let(:verifier) { described_class.new(secret_key: secret) }

  it 'verifies correct signature' do
    sig = verifier.compute_signature(body)
    expect(verifier.verify?(body, sig)).to be true
  end

  it 'rejects invalid signature' do
    expect(verifier.verify?(body, 'invalid')).to be false
  end

  it 'rejects when missing data' do
    expect(verifier.verify?(nil, nil)).to be false
  end
end
