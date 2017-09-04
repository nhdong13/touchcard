class OrdersCreateJob < ActiveJob::Base

  def perform(shop_domain:, webhook:)
    shop = Shop.find_by(domain: shop_domain)
    shop.with_shopify_session do
      shopify_order = ShopifyAPI::Order.find(webhook["id"])
      order = Order.from_shopify!(shopify_order, shop)
      order.connect_to_postcard
      return puts "no customer" unless order.customer
      return puts "no default address" unless shopify_order&.customer&.default_address
      return puts "no street in address" unless shopify_order.customer.default_address&.address1&.present?
      default_address = shopify_order.customer.default_address
      international = default_address.country_code != "US"

      # Only new customers recieve postcards at the moment
      return puts  "Not a new customer" unless order.customer.new_customer?
      # Create a new card and schedule to send
      post_sale_order = shop.card_orders.find_by(
        enabled: true,
        type: "PostSaleOrder")
      return puts "Card not setup" if post_sale_order.nil?
      return puts "Card not enabled" unless post_sale_order.enabled?
      return puts "international customer not enabled" if international && !post_sale_order.international?
      return puts "order filtered out" unless post_sale_order.send_postcard?(order)
      postcard = Postcard.new(
        customer: order.customer,
        order: order,
        card_order: post_sale_order,
        send_date: post_sale_order.send_date,
        paid: false)
      postcard.pay.save! if postcard.can_afford?
    end
  end
end
