# frozen_string_literal: true

require 'spec_helper'
require 'action_view'
require 'action_controller'

RSpec.describe Tosspayments2::Rails::ScriptTagHelper do
  let(:view) do
    paths = ActionView::PathSet.new
    lookup_context = ActionView::LookupContext.new(paths)
    assigns = {}.freeze
    controller = ActionController::Base.new
    klass = Class.new(ActionView::Base) do
      include Tosspayments2::Rails::ScriptTagHelper
    end
    klass.new(lookup_context, assigns, controller)
  end

  before do
    Tosspayments2::Rails.configure do |c|
      c.client_key = 'ck_test_x'
      c.secret_key = 'sk_test_x'
    end
  end

  it 'renders script tag with versioned src' do
    html = view.tosspayments_script_tag
    expect(html).to include('<script')
    expect(html).to include('https://js.tosspayments.com/v2/standard')
  end
end
