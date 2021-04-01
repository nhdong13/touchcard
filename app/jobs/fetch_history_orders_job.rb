class FetchHistoryOrdersJob < ActiveJob::Base
  queue_as :default

  def perform(shop, time_delay)
    return if shop.shopify_history_data_imported.present?
    processed_at_max = DateTime.now
    processed_at_min = processed_at_max - time_delay.weeks
    params = {status: "any",
              limit: 250,
              processed_at_min: processed_at_min.iso8601,
              processed_at_max: processed_at_max.iso8601
              }

    shop.with_shopify_session do
      shopify_orders = ShopifyAPI::Order.all(params: params)
      # second_page_shopify_orders  ShopifyAPI::Product.find(params: params.merge({page_info: first_page_shopify_orders.next_page_info })
      shopify_orders.each do |shopify_order|
        begin
          order = Order.from_shopify!(shopify_order, shop)
        rescue ActiveRecord::RecordInvalid
          return puts "unable to create order (duplicate webhook?)"
        end

        order.connect_to_postcard
        next  puts "no customer" unless order.customer
        next puts "no default address" unless shopify_order.customer.respond_to?(:default_address)
        next puts "no default address" unless shopify_order.customer.default_address
        next puts "no street in address" unless shopify_order.customer.default_address&.address1&.present?

        # Currently only new customers receive postcards
        next puts "customer already exists" unless order.customer.new_customer?

        default_address = shopify_order.customer.default_address
        international = default_address.country_code != "US"

        # Create a new card
        post_sale_order = shop.card_orders.find_by(enabled: true, type: "PostSaleOrder")
        next puts "Card not setup" if post_sale_order.nil?
        next puts "Card not enabled" unless post_sale_order.enabled?
        result = post_sale_order.prepare_for_sending(order, "history")
      end
    end
    shop.update(shopify_history_data_imported: processed_at_max, shopify_history_data_imported_duration: time_delay)
  end
end
