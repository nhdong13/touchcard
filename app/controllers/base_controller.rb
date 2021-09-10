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
      @current_shop.update(last_login_at: Time.now, uninstalled_at: nil)
      check_webhooks_installed
      # HandlingErrorCampaignCompleteJob.perform_later(@current_shop)
    end
  end

  def render_authorization_error
    render json: { errors: "Forbidden"}, status: 401
  end

  def check_webhooks_installed
    @current_shop.with_shopify_session do
      whs = ShopifyAPI::Webhook.find :all
      if whs.size != 3
        webhooks = [
          { topic: "orders/create", format: "json", fields: %w(id customer), address: "#{ENV['APP_URL']}/new_order" },
          { topic: 'orders/fulfilled', format: "json", fields: %w(id customer), address: "#{ENV['APP_URL']}/orders_fulfilled"},
          { topic: "app/uninstalled", format: "json", fields: %w(id domain), address: "#{ENV['APP_URL']}/uninstall" }
        ]
        ShopifyApp::WebhooksManagerJob.perform_now(shop_domain: @current_shop.domain, shop_token: @current_shop.token, webhooks: webhooks)
      end
    end
  end
end
