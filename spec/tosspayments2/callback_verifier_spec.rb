# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Tosspayments2::Rails::CallbackVerifier do
  let(:verifier) { described_class.new }

  it 'returns true when amount matches' do
    expect(
      verifier.match_amount?(order_id: 'o1', amount: 100) { |id| id == 'o1' ? 100 : 0 }
    ).to be true
  end

  it 'raises VerificationError when mismatch' do
    expect do
      verifier.match_amount?(order_id: 'o1', amount: 150) { |_id| 100 }
    end.to raise_error(Tosspayments2::Rails::VerificationError)
  end
end
