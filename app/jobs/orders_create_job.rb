class OrdersCreateJob < ActiveJob::Base
  queue_as :default

  def perform(shop_domain:, webhook:)
    shop = Shop.find_by(domain: shop_domain)
    shop.with_shopify_session do
      shopify_orders = webhook[:orders]
      shopify_orders.each do |shopify_order|
        order = Order.from_shopify!(shopify_order, shop)
        order.connect_to_postcard
        return logger.info "no customer" unless order.customer
        return logger.info "no default address" unless shopify_order.customer.respond_to?(:default_address)
        return logger.info "no default address" unless shopify_order.customer.default_address
        default_address = shopify_order.customer.default_address
        international = default_address.country_code != "US"

        # Only new customers recieve postcards at the moment
        return logger.info "Not a new customer" unless order.customer.new_customer?
        # Create a new card and schedule to send
        post_sale_order = shop.card_orders.find_by(
          enabled: true,
          type: "PostSaleOrder")
        return logger.info "Card not setup" if post_sale_order.nil?
        return logger.info "Card not enabled" unless post_sale_order.enabled?
        return logger.info "international customer not enabled" if international && !post_sale_order.international?
        return logger.info "order filtered out" unless post_sale_order.send_postcard?(order)
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
end
