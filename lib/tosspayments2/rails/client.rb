# frozen_string_literal: true

require 'net/http'
require 'json'
require 'base64'

module Tosspayments2
  module Rails
    # Lightweight client for TossPayments REST endpoints (confirm/cancel only).
    class Client
      # @param secret_key [String,nil]
      # @param api_base [String,nil]
      # @param timeout [Integer,nil] network timeout seconds
      # @param retries [Integer] transient network retry attempts
      # @param backoff [Float] linear backoff base seconds
      def initialize(secret_key: nil, api_base: nil, timeout: nil, retries: 2, backoff: 0.2)
        cfg = ::Tosspayments2::Rails.configuration
        @secret_key = secret_key || cfg.secret_key
        @api_base = api_base || cfg.api_base
        @timeout = timeout || cfg.timeout
        @retries = retries
        @backoff = backoff
        return if @secret_key

        raise ::Tosspayments2::Rails::ConfigurationError,
              'secret_key required – configure with Tosspayments2::Rails.configure'
      end

      # Confirm payment after success redirect.
      # @return [Hash] parsed JSON
      # @raise [APIError]
      def confirm(payment_key:, order_id:, amount:)
        post_json('/v1/payments/confirm', {
                    paymentKey: payment_key,
                    orderId: order_id,
                    amount: amount
                  })
      end

      # Cancel payment (full or partial).
      # @return [Hash]
      # @raise [APIError]
      def cancel(payment_key:, cancel_reason:, amount: nil)
        body = { cancelReason: cancel_reason }
        body[:cancelAmount] = amount if amount
        post_json("/v1/payments/#{payment_key}/cancel", body)
      end

      private

      def post_json(path, body)
        uri = URI.join(@api_base, path)
        req = Net::HTTP::Post.new(uri)
        req['Authorization'] = "Basic #{Base64.strict_encode64("#{@secret_key}:")}"
        req['Content-Type'] = 'application/json'
        req.body = JSON.dump(body)
        perform(uri, req)
      end

      def perform(uri, req)
        attempts = 0
        loop do
          attempts += 1
          res = execute_http(uri, req)
          return parse_body(res) if res.is_a?(Net::HTTPSuccess)
          raise build_api_error(res) unless retryable?(res, attempts)

          sleep(@backoff * attempts)
        end
      rescue Timeout::Error, Errno::ECONNRESET, Errno::ETIMEDOUT, SocketError => e
        retry if (attempts += 1) <= @retries
        raise ::Tosspayments2::Rails::APIError.new("Network error: #{e.class}", status: 0, body: { error: e.message })
      end

      def execute_http(uri, req)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == 'https'
        http.read_timeout = @timeout
        http.open_timeout = @timeout
        http.request(req)
      end

      def parse_body(res)
        JSON.parse(res.body, symbolize_names: true)
      rescue JSON::ParserError
        { raw: res.body }
      end

      def build_api_error(res)
        parsed = parse_body(res)
        request_id = res['X-Request-Id'] || res['X-Request-ID']
        meta = parsed.is_a?(Hash) ? parsed : { raw: parsed }
        ::Tosspayments2::Rails::APIError.new(
          "TossPayments API error #{res.code}",
          status: res.code.to_i,
          body: meta,
          request_id: request_id
        )
      end

      def retryable?(res, attempts)
        attempts <= @retries && res.code.to_i >= 500
      end
    end
  end
end
