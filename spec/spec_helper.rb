# frozen_string_literal: true
require 'simplecov'
SimpleCov.start do
  enable_coverage :branch
  add_filter '/spec/'
end

require 'rspec'
require_relative '../lib/tosspayments2/rails'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
