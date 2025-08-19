# frozen_string_literal: true

module Tosspayments2
  module Rails
    # Rails engine for auto-loading helpers and configuration.
    class Engine < ::Rails::Engine
      isolate_namespace Tosspayments2::Rails

      initializer "tosspayments2.configure" do |app|
        app.config.tosspayments2 ||= ActiveSupport::OrderedOptions.new
        app_cfg = app.config.tosspayments2
        ::Tosspayments2::Rails.configure do |c|
          c.client_key ||= app_cfg.client_key || ENV["TOSSPAYMENTS_CLIENT_KEY"]
            c.secret_key ||= app_cfg.secret_key || ENV["TOSSPAYMENTS_SECRET_KEY"]
          c.widget_version ||= app_cfg.widget_version || "v2"
          c.api_base ||= app_cfg.api_base || "https://api.tosspayments.com"
          c.timeout ||= app_cfg.timeout || 10
        end
      end

      initializer "tosspayments2.helpers" do
        ActiveSupport.on_load :action_view do
          include ::Tosspayments2::Rails::ScriptTagHelper
        end
        ActiveSupport.on_load :action_controller do
          helper ::Tosspayments2::Rails::ScriptTagHelper
        end
      end
    end
  end
end
