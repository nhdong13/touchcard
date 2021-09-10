class OrdersFulfilledJob < ActiveJob::Base
  def perform(arg)
    shop_domain = arg[:shop_domain]
    webhook = arg[:webhook]
    shop = Shop.find_by(domain: shop_domain)
    shop.with_shopify_session do
      shopify_order = ShopifyAPI::Order.find(webhook["id"])
      begin
        order = Order.find_by(shopify_id: webhook["id"])
        order.update!(fulfillment_status: "fulfilled") if order.present?
      rescue ActiveRecord::RecordInvalid
        false
      end
    end
  end
end
