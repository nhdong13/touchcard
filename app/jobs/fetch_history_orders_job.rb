class FetchHistoryOrdersJob < ActiveJob::Base
  queue_as :default

  def perform(shop)
    processed_at_max = DateTime.now
    params = {status: "any",
              limit: 250,
              processed_at_max: processed_at_max.iso8601
              }

    shop.with_shopify_session do
      shopify_orders = ShopifyAPI::Order.all(params: params)
      while true
        shopify_orders.each do |shopify_order|
          begin
            result = Order.from_shopify!(shopify_order, shop)
            order = result[:order]
            is_order_exists = result[:is_order_exists]
          rescue ActiveRecord::RecordInvalid
            next Rails.logger.debug "unable to create order (duplicate webhook?)"
          end
          next if is_order_exists

          order.connect_to_postcard
          next Rails.logger.debug "no customer" unless order.customer
          next Rails.logger.debug "no default address" unless shopify_order.customer.respond_to?(:default_address)
          next Rails.logger.debug "no default address" unless shopify_order.customer.default_address
          next Rails.logger.debug "no street in address" unless shopify_order.customer.default_address&.address1&.present?

          # # Currently only new customers receive postcards
          # next puts "customer already exists" if order.customer.postcards.where(data_source_status: "history").count > 0

          # default_address = shopify_order.customer.default_address
          # international = default_address.country_code != "US"

          # # Create a new card
          # post_sale_order = shop.card_orders.find_by(type: "PostSaleOrder")
          # post_sale_order.prepare_for_sending(order, "history")
        end

        break unless shopify_orders.next_page?
        shopify_orders = shopify_orders.fetch_next_page
      end
    end
    shop.update(shopify_history_data_imported: processed_at_max, shopify_history_data_imported_duration: time_delay)
  end
end
