# frozen_string_literal: true

require 'active_support/concern'
module Tosspayments2
  module Rails
    module ControllerConcern
      extend ActiveSupport::Concern

      private

      def toss_client
        @toss_client ||= ::Tosspayments2::Rails::Client.new
      end
    end
  end
end
