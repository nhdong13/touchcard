require "slack_notify"

class WebhookController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :verify_webhook, only: [:new_order, :uninstall]
  before_action :check_order, only: [:new_order]
  before_action :set_shop_session, only: [:new_order, :uninstall]
  before_action :set_shopify_order, only: [:new_order]

  def new_order
    head :ok # head ok to avoid timeout
    ProcessOrder.new(@shop, @shopify_order, logger).call
  end

  def uninstall
    head :ok
    @shop.subscriptions.each { |s| s.destroy }
    @shop.update_attributes(credit: 0)
    SlackNotify.uninstall(@shop.domain)
  end

  private
  def set_shopify_order
    # TODO: this is actually passed in as params don't have an extra request!
    @shopify_order = ShopifyAPI::Order.find(params[:id])
    return head :not_found unless @shopify_order
  end

  def set_shop_session
    domain = request.headers["X-Shopify-Shop-Domain"]
    @shop = Shop.find_by(domain: domain)
    return head :not_found unless @shop
    @shop.new_sess
  end

  def check_order
    order = Order.find_by(shopify_id: params[:id])
    return unless order
    logger.info "order id:#{params[:id]} already processed"
    head :ok
  end

  def verify_webhook
    data = request.body.read.to_s
    hmac_header = request.headers["HTTP_X_SHOPIFY_HMAC_SHA256"]
    digest = OpenSSL::Digest.new("sha256")
    api_secret = ENV["SHOPIFY_CLIENT_API_SECRET"]
    digested = OpenSSL::HMAC.digest(digest, api_secret, data)
    calculated_hmac = Base64.encode64(digested).strip
    byebug unless calculated_hmac == hmac_header
    head :unauthorized unless calculated_hmac == hmac_header
    request.body.rewind
  end
end
