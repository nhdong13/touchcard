class FetchHistoryOrdersJob < ActiveJob::Base
  queue_as :default

  def perform(shop_id)
    @shop = Shop.find(shop_id)
    params = { created_at_min: Date.current - 60.days, status: 'any', limit: 250 }
    @shop.with_shopify_session do
      shopify_orders = ShopifyAPI::Order.all(params: params)
      import_orders(shopify_orders)
      loop do
        break unless shopify_orders.next_page?
        shopify_orders = shopify_orders.fetch_next_page
        import_orders(shopify_orders)
      end
    end
  end

  private
  def import_orders shopify_orders
    shopify_orders.each do |shopify_order|
      begin
        result = Order.from_shopify!(shopify_order, @shop)
      rescue ActiveRecord::RecordInvalid
        next Rails.logger.debug "unable to create order (duplicate webhook?)"
      end
    end
  end
end
