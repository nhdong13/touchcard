class FetchHistoryOrdersJob < ActiveJob::Base
  queue_as :default

  def perform(shop)
    params = { created_at_min: Date.current - 60.days }

    shop.with_shopify_session do
      shopify_orders = ShopifyAPI::Order.all(params: params)
      shopify_orders.each do |shopify_order|
        begin
          result = Order.from_shopify!(shopify_order, shop)
        rescue ActiveRecord::RecordInvalid
          next Rails.logger.debug "unable to create order (duplicate webhook?)"
        end
      end
    end
  end
end
