# frozen_string_literal: true

require 'rails/generators'
module Tosspayments2
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)
      class_option :controller, type: :boolean, default: false, desc: 'Generate example payments controller'

      def create_initializer
        template 'initializer.rb', 'config/initializers/tosspayments2.rb'
      end

      def create_controller
        return unless options[:controller]

        template 'payments_controller.rb', 'app/controllers/payments_controller.rb'
      end
    end
  end
end
