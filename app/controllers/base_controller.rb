# frozen_string_literal: true

class BaseController < ApplicationController
  include ShopifyApp::Authenticated

  before_action :require_auth
  skip_around_action :shopify_session if Rails.configuration.fullscreen_debug

  def require_auth
    return @current_shop ||= Shop.where(domain:"SAMPLE_DATA").first if Rails.configuration.fullscreen_debug
    if session[:shopify].nil?
      render_authorization_error
    else
      @current_shop ||= Shop.find(session[:shopify])
      @current_shop.update_attributes(last_login_at: Time.now, uninstalled_at: nil)
    end
  end

  def render_authorization_error
    render json: { errors: "Forbidden"}, status: 401
  end
end
