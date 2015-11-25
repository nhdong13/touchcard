require "slack_notify"

class WebhookController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :verify_webhook, only: [:new_order, :uninstall]

  def new_order
    # TODO: get rid of all the puts!! Should be using rails logger
    domain = request.headers["X-Shopify-Shop-Domain"]
    head :ok # head ok to avoid timeout
    shop = Shop.find_by(domain: domain)
    logger.info "***********************"
    logger.info "New order from #{domain}"
    logger.info "***********************"
    shop.new_sess
    order = ShopifyAPI::Order.find(params[:id])
    customer = order.customer
    international = customer.default_address.country_code == "US"

    # Check if this is the customer's first order
    return puts "Not a new customer, order_count: #{customer.orders_count}" unless customer.orders_count.to_i <= 1

    # Check if there is a card already (duplicate webhook)
    duplicate = Postcard.find_by(triggering_shopify_order_id: order.id)
    return logger.info "Duplicate card found" if duplicate

    # Create a new card and schedule to send
    post_sale_order = shop.card_orders.find_by(
      enabled: true,
      type: "PostSaleOrder")
    return logger.info "Card not setup" if post_sale_order.nil?
    return logger.info "Card not enabled" unless post_sale_order.enabled?
    return logger.info "international customer not enabled" if international && !post_sale_order.international?
    Postcard.create_postcard!(post_sale_order, customer, order.id)
  end

  def uninstall
    head :ok
    shop = Shop.find_by(shopify_id: params[:id])
    fail "Uninstall non existing shop #{params[:id]}" if shop.nil?
    shop.subscriptions.each { |s| s.destroy }
    # TODO: have a better uninstall path, we probably don't want to be deleting
    SlackNotify.uninstall(shop.domain)
    shop.destroy
  end

  private

  def verify_webhook
    data = request.body.read.to_s
    hmac_header = request.headers["HTTP_X_SHOPIFY_HMAC_SHA256"]
    digest = OpenSSL::Digest::Digest.new("sha256")
    api_secret = ENV["SHOPIFY_CLIENT_API_SECRET"]
    digested = OpenSSL::HMAC.digest(digest, api_secret, data)
    calculated_hmac = Base64.encode64(digested).strip
    head :unauthorized unless calculated_hmac == hmac_header
    request.body.rewind
  end
end
