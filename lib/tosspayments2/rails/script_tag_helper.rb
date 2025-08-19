# frozen_string_literal: true

require 'erb'

module Tosspayments2
  module Rails
    module ScriptTagHelper
      def tosspayments_script_tag(async: true, defer: true, version: nil)
        v = version || ::Tosspayments2::Rails.configuration.widget_version
        src = "https://js.tosspayments.com/#{v}/standard"
        attrs = []
        attrs << 'async' if async
        attrs << 'defer' if defer
        attrs << %(src="#{ERB::Util.html_escape(src)}")
        "<script #{attrs.join(' ')}></script>".html_safe
      end
    end
  end
end
