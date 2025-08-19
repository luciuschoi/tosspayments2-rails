# frozen_string_literal: true

require 'singleton'
require 'logger'

module Tosspayments2
  module Rails
    class Configuration
      include Singleton
      attr_accessor :client_key, :secret_key, :widget_version, :api_base, :timeout, :logger

      def initialize
        @widget_version = 'v2'
        @api_base = 'https://api.tosspayments.com'
        @timeout = 10
        @logger = defined?(::Rails) ? ::Rails.logger : Logger.new($stdout)
      end
    end

    class << self
      def configuration
        Configuration.instance
      end

      def configure
        yield(configuration) if block_given?
        configuration
      end
    end
  end
end
