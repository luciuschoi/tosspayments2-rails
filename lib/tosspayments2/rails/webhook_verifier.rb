# frozen_string_literal: true

require 'openssl'
require 'base64'

module Tosspayments2
  module Rails
    # Verifies incoming webhook using HMAC-SHA256 signature (Base64 encoded).
    # Assumes TossPayments sends header 'X-TossPayments-Signature'.
    class WebhookVerifier
      HEADER_NAME = 'X-TossPayments-Signature'

      def initialize(secret_key: nil)
        @secret_key = secret_key || ::Tosspayments2::Rails.configuration.secret_key
        return if @secret_key

        raise ::Tosspayments2::Rails::ConfigurationError,
              'secret_key required for webhook verification'
      end

      # @param body [String] raw request body
      # @param signature [String,nil] header signature value (Base64)
      # @return [Boolean]
      def verify?(body, signature)
        return false unless body && signature

        expected = compute_signature(body)
        secure_compare?(signature, expected)
      end

      # Compute signature for a given body
      def compute_signature(body)
        digest = OpenSSL::HMAC.digest('sha256', @secret_key, body)
        Base64.strict_encode64(digest)
      end

      private

      # Constant-time compare
      def secure_compare?(given_sig, expected_sig)
        return false unless given_sig.bytesize == expected_sig.bytesize

        l = given_sig.unpack('C*')
        res = 0
        expected_sig.each_byte { |byte| res |= byte ^ l.shift }
        res.zero?
      end
    end
  end
end
