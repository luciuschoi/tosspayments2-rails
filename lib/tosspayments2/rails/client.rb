# frozen_string_literal: true

require 'net/http'
require 'json'
require 'base64'

module Tosspayments2
  module Rails
    # Lightweight client for TossPayments REST endpoints.
    class Client
      class HTTPError < StandardError
        attr_reader :response
        def initialize(message, response)
          super(message)
          @response = response
        end
      end

      def initialize(secret_key: nil, api_base: nil, timeout: nil)
        cfg = ::Tosspayments2::Rails.configuration
        @secret_key = secret_key || cfg.secret_key
        @api_base = api_base || cfg.api_base
        @timeout = timeout || cfg.timeout
        raise ArgumentError, 'secret_key required' unless @secret_key
      end

      def confirm(payment_key:, order_id:, amount:)
        post_json('/v1/payments/confirm', {
          paymentKey: payment_key,
          orderId: order_id,
          amount: amount
        })
      end

      def cancel(payment_key:, cancel_reason:, amount: nil)
        body = { cancelReason: cancel_reason }
        body[:cancelAmount] = amount if amount
        post_json("/v1/payments/#{payment_key}/cancel", body)
      end

      private

      def post_json(path, body)
        uri = URI.join(@api_base, path)
        req = Net::HTTP::Post.new(uri)
        req['Authorization'] = 'Basic ' + Base64.strict_encode64(@secret_key + ':')
        req['Content-Type'] = 'application/json'
        req.body = JSON.dump(body)
        perform(uri, req)
      end

      def perform(uri, req)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == 'https'
        http.read_timeout = @timeout
        http.open_timeout = @timeout
        res = http.request(req)
        parsed = begin
          JSON.parse(res.body, symbolize_names: true)
        rescue JSON::ParserError
          { raw: res.body }
        end
        unless res.is_a?(Net::HTTPSuccess)
          raise HTTPError.new("TossPayments API error #{res.code}", parsed)
        end
        parsed
      end
    end
  end
end
