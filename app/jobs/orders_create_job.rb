class OrdersCreateJob < ActiveJob::Base

  def perform(arg)
    shop_domain = arg[:shop_domain]
    webhook = arg[:webhook]
    shop = Shop.find_by(domain: shop_domain)
    shop.with_shopify_session do
      shopify_order = ShopifyAPI::Order.find(webhook["id"])

      begin
        order = Order.from_shopify!(shopify_order, shop)
      rescue ActiveRecord::RecordInvalid
        return puts "unable to create order (duplicate webhook?)"
      end

      order.connect_to_postcard
      # return puts "no customer" unless order.customer
      # return puts "no default address" unless shopify_order.customer.respond_to?(:default_address)
      # return puts "no default address" unless shopify_order.customer.default_address
      # return puts "no street in address" unless shopify_order.customer.default_address&.address1&.present?

      # # TODO: Unused Automations Code
      # #
      # # # Schedule to send lifetime purchase postcard if customer is eligible for lifetime reward
      # # ProcessLifetimePurchase.new(order.customer, shop).call
      # # # TODO: Have standard way of handling "purchase triggered postcards" and make sure we don't send multiple
      # # # cards for a triggered purchase unless a retailer absolutely wants that

      # # Currently only new customers receive postcards
      # return puts "customer already exists" unless order.customer.new_customer?(shop.id)

      # default_address = shopify_order.customer.default_address
      # international = default_address.country_code != "US"

      # # Create a new card and schedule to send
      # post_sale_orders = shop.card_orders.where(enabled: true, type: "PostSaleOrder")
      # # return puts "Card not setup" if post_sale_orders.nil?
      # # return puts "Card not enabled" unless post_sale_orders.enabled?

      # post_sale_orders.each{|post_sale_order| post_sale_order.prepare_for_sending(order) }
    end
  end
end
