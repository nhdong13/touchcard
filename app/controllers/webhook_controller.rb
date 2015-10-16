class WebhookController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :verify_webhook, only: [:new_order, :uninstall]

  def new_order
    domain = request.headers["X-Shopify-Shop-Domain"]
    head :ok
    shop = Shop.find_by(:domain => domain)
    puts "***********************"
    puts "New order from #{domain}"
    puts "***********************"
    if shop.enabled and shop.credit >= 1
      shop.new_sess
      order = ShopifyAPI::Order.find(params[:id])
      customer = order.customer
      puts customer.orders_count

      # Check if this is the customer's first order
      if customer.orders_count == 0

        #Check if there is a card already (duplicate webhook)
        duplicate = Card.where(:order_id => order.id) || nil

        if duplicate == nil
          # Create a new card and schedule to send
          mc = shop.master_card
          card = shop.cards.create(
            :template       => mc.template,
            :logo           => mc.logo,
            :image_front    => mc.image_front,
            :image_back     => mc.image_back,
            :title_back     => mc.title_front,
            :text_front     => mc.text_front,
            :text_back      => mc.text_back,
            :customer_name  => customer.first_name + " " + customer.last_name,
            :customer_id    => customer.id,
            :addr1          => order.shipping_address.address1,
            :addr2          => order.shipping_address.address2,
            :city           => order.shipping_address.city,
            :state          => order.shipping_address.province_code,
            :country        => order.shipping_address.country_code,
            :zip            => order.shipping_address.zip,
            :send_date      => (Date.today + shop.send_delay),
            :order_id       => order.id
          )
        end

        # TODO: Remove after alpha
        card.send_card
      else
        puts "Duplicate card found"
        head :ok
      end
    else
      puts "Recieved new order from #{domain}, but shop is not enabled or has no credits"
      head :ok
    end

    # Respond to webhook again...
    head :ok
  end

  def uninstall
    require 'slack_notify'
    head :ok
    shop = Shop.find_by(:shopify_id => params[:id])
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
    calculated_hmac = Base64.encode64(OpenSSL::HMAC.digest(digest, ShopifyApp.configuration.secret, data)).strip
    unless calculated_hmac == hmac_header
      head :unauthorized
    end
    request.body.rewind
  end
end
