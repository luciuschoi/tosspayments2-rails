# frozen_string_literal: true

module Tosspayments2
  module Rails
    class CallbackVerifier
      def match_amount?(order_id:, amount:, &block)
        raise ArgumentError, 'block required' unless block

        expected = block.call(order_id)
        unless expected.to_i == amount.to_i
          raise ::Tosspayments2::Rails::VerificationError,
                "Amount mismatch expected=#{expected} got=#{amount}"
        end

        true
      end
    end
  end
end
