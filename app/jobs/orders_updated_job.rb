class OrdersUpdatedJob < ActiveJob::Base
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
    end
  end
end
