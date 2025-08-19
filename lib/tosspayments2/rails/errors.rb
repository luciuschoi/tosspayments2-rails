# frozen_string_literal: true

module Tosspayments2
  module Rails
    class Error < StandardError; end
    class ConfigurationError < Error; end
    class VerificationError < Error; end

    class APIError < Error
      attr_reader :status, :body, :code, :request_id

      def initialize(message, status:, body: nil, request_id: nil)
        super(message)
        @status = status
        @body = body
        @code = (body && body[:code]) || (body && body[:errorCode])
        @request_id = request_id || (body && body[:request_id])
      end
    end
  end
end
