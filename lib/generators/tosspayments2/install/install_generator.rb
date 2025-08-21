# frozen_string_literal: true

require 'rails/generators'
module Tosspayments2
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      class_option :controller, type: :boolean, default: false, desc: 'Generate example payments controller'
      class_option :with_model, type: :boolean, default: true,
                                desc: 'Generate Payment model, migration, and views'

      def create_initializer
        template 'initializer.rb', 'config/initializers/tosspayments.rb'
      end

      def create_controller
        return unless options[:controller]

        template 'payments_controller.rb', 'app/controllers/payments_controller.rb'
        template 'payments_helper.rb', 'app/helpers/payments_helper.rb'
      end

      def create_stimulus_controller
        return unless options[:with_model]

        # app/javascript/controllers 디렉토리 생성
        empty_directory 'app/javascript/controllers'

        # Stimulus 컨트롤러 파일 복사
        template 'tosspayments_checkout_controller.js', 'app/javascript/controllers/tosspayments_checkout_controller.js'
      end

      def create_css_file
        return unless options[:with_model]

        # app/assets/stylesheets 디렉토리 생성
        empty_directory 'app/assets/stylesheets'

        # CSS 파일 복사
        template 'tosspayments.css', 'app/assets/stylesheets/tosspayments.css'

        # application.css에 import 추가
        add_css_import_to_application
      end

      private

      def add_css_import_to_application
        application_css_path = 'app/assets/stylesheets/application.css'
        import_line = ' *= require tosspayments'

        if File.exist?(application_css_path)
          unless File.read(application_css_path).include?(import_line)
            # application.css의 *= require_tree . 라인 바로 위에 추가
            content = File.read(application_css_path)
            if content.include?('*= require_tree .')
              content.gsub!('*= require_tree .', "#{import_line}\n *= require_tree .")
              File.write(application_css_path, content)
            else
              append_to_file application_css_path, "\n#{import_line}\n"
            end
            say 'Added tosspayments.css import to application.css', :green
          end
        else
          say "Warning: application.css not found. Please manually add '#{import_line}' to your CSS manifest.", :yellow
        end
      end

      def create_payment_model_and_migration
        return unless options[:with_model]

        # Payment 모델 생성
        template 'payment.rb', 'app/models/payment.rb'

        # 마이그레이션 파일명에 타임스탬프 추가
        timestamp = Time.now.utc.strftime('%Y%m%d%H%M%S')
        migration_file = "db/migrate/#{timestamp}_create_payments.rb"
        template 'migration.rb', migration_file

        # 뷰 파일 생성
        empty_directory 'app/views/payments'
        template 'index.html.erb', 'app/views/payments/index.html.erb'
        template 'show.html.erb', 'app/views/payments/show.html.erb'
        template 'new.html.erb', 'app/views/payments/new.html.erb'
        template 'checkout.html.erb', 'app/views/payments/checkout.html.erb'
      end

      def add_payments_route
        route <<~RUBY
          resources :payments do
            collection do
              get :checkout
              get :success
              get :fail
            end
            member do
              patch :cancel
            end
          end
        RUBY
      end

      # 제너레이터 실행 시 자동으로 모델/마이그레이션/뷰 생성
      def install
        create_payment_model_and_migration
        create_stimulus_controller
        create_css_file
        add_payments_route
      end

      # Thor의 hook으로 install 메서드가 자동 실행되도록 설정
      private_class_method def self.default_task
        :install
      end
    end
  end
end
