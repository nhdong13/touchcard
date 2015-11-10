class WebhookController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :verify_webhook, only: [:new_order, :uninstall]

  def new_order
    domain = request.headers["X-Shopify-Shop-Domain"]
    head :ok
    shop = Shop.find_by(domain: domain)
    puts "***********************"
    puts "New order from #{domain}"
    puts "***********************"
    shop.new_sess
    order = ShopifyAPI::Order.find(params[:id])
    customer = order.customer

    # Check if this is the customer's first order
    if customer.orders_count <= 1

      #Check if there is a card already (duplicate webhook)
      duplicate = Postcard.where(order_id: order.id)[0] || nil

      if duplicate.nil?
        # Create a new card and schedule to send
        ps_template = shop.postsale_templates.where(status: "sending").first

        # Create a new postcard if sending is enabled and they have enough credits
        if ps_template.enabled? and customer.default_address.country_code == "US" and shop.credit >= 1
          Postcard.create_postcard(ps_template.id, customer, order.id)
        elsif ps_template.enabled? and customer.default_address.country_code != "US" and ps_teplate.international? and shop.credit >= 2
          Postcard.create_postcard(ps_template.id, customer, order.id)
        else
          puts "Not Enabled or not enough credits"
          head :ok
        end
      else
        puts "Duplicate card found"
        head :ok
      end
    else
      puts "Not a new customer"
      head :ok
    end
  end

  def uninstall
    require 'slack_notify'
    head :ok
    shop = Shop.find_by(shopify_id: params[:id])
    unless shop.nil?
      #delete shop
      shop.destroy

      #send notification to slack
      SlackNotify.uninstall(shop.domain)

      #respond to webhook again
      head :ok
    end
  end

  private

  def verify_webhook
    data = request.body.read.to_s
    hmac_header = request.headers['HTTP_X_SHOPIFY_HMAC_SHA256']
    digest  = OpenSSL::Digest::Digest.new('sha256')
    calculated_hmac = Base64.encode64(OpenSSL::HMAC.digest(digest, ENV['SHOPIFY_CLIENT_API_SECRET'], data)).strip
    unless calculated_hmac == hmac_header
      head :unauthorized
    end
    request.body.rewind
  end
end
