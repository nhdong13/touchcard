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
    shop.new_sess
    order = ShopifyAPI::Order.find(params[:id])
    customer = order.customer

    # Check if this is the customer's first order
    if customer.orders_count <= 1

      #Check if there is a card already (duplicate webhook)
      duplicate = Postcard.where(:order_id => order.id)[0] || nil

      if duplicate.nil?
        # Create a new card and schedule to send
        ps_template = shop.postsale_templates.where(:status => "sending").first
        if ps_template.enabled?
          postcard = ps_template.postcards.new(
            :order_id       => order.id,
            :customer_id    => customer.id,
            :customer_name  => customer.first_name + " " + customer.last_name,
            :addr1          => order.shipping_address.address1,
            :addr2          => order.shipping_address.address2,
            :city           => order.shipping_address.city,
            :state          => order.shipping_address.province_code,
            :country        => order.shipping_address.country_code,
            :zip            => order.shipping_address.zip,
            :send_date      => (Date.today + shop.send_delay),
          )

          if postcard.country == "US" and shop.credit >= 1
            postcard.save
            postcard.delay.send_card
          elsif postcard.country != "US" and ps_template.international? and shop.credit >= 2
            postcard.save
            postcard.delay.send_card
          else
            return
          end

        else
          puts "Not Enabled"
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
    calculated_hmac = Base64.encode64(OpenSSL::HMAC.digest(digest, ENV['SHOPIFY_CLIENT_API_SECRET'], data)).strip
    unless calculated_hmac == hmac_header
      head :unauthorized
    end
    request.body.rewind
  end
end
