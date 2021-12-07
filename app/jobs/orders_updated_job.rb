class OrdersUpdatedJob < ActiveJob::Base
  def perform(arg)
    shop_domain = arg[:shop_domain]
    webhook = arg[:webhook]
    order_before = Order.find_by(shopify_id: webhook["id"])
    if order_before.present?
      shop = Shop.find_by(domain: shop_domain)
      shop.with_shopify_session do
        shopify_order = ShopifyAPI::Order.find(webhook["id"])
        begin
          order = Order.from_shopify!(shopify_order, shop)
        rescue ActiveRecord::RecordInvalid
          return puts "unable to create order (duplicate webhook?)"
        end
      end
    else
      return puts "Can't find this order in database"
    end
  end
end
