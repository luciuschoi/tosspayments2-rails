# frozen_string_literal: true

module Tosspayments2
  module Rails
    class WebhookVerifier
      def initialize(secret_key: nil)
        @secret_key = secret_key || ::Tosspayments2::Rails.configuration.secret_key
      end

      def verify(_body, _signature)
        true
      end
    end
  end
end
