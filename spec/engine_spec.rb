# frozen_string_literal: true

require 'spec_helper'
require 'rails'
require 'action_controller'
require_relative '../lib/tosspayments2/rails'
require 'tosspayments2/rails/engine'

RSpec.describe Tosspayments2::Rails::Engine do
  it 'isolates namespace' do
    expect(described_class.isolated?).to be true
  end

  it 'loads configuration via initializer' do
    Tosspayments2::Rails.configure do |c|
      c.client_key = 'ck'
      c.secret_key = 'sk'
    end
    expect(Tosspayments2::Rails.configuration.client_key).to eq('ck')
  end
end
