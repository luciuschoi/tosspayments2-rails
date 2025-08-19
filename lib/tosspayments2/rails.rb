# frozen_string_literal: true

require_relative 'rails/version'
require_relative 'rails/configuration'
require_relative 'rails/errors'
require_relative 'rails/client'
require_relative 'rails/script_tag_helper'
require_relative 'rails/controller_concern'
require_relative 'rails/webhook_verifier'
require_relative 'rails/callback_verifier'
require_relative 'rails/engine' if defined?(Rails)

module Tosspayments2
  module Rails
    class Error < StandardError; end

    def self.configure(&block)
      configuration = ::Tosspayments2::Rails.configuration
      yield(configuration) if block
      configuration
    end
  end
end
