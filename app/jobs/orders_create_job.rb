class OrdersCreateJob < ApplicationJob

  def perform(shop_domain:, webhook:)
    shop = Shop.find_by(domain: shop_domain)
    shop.with_shopify_session do
      shopify_order = ShopifyAPI::Order.find(webhook["id"])
      ProcessOrder.new(shop, shopify_order, logger).call
    end
  end
end
