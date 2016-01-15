class FillLineItems < ActiveRecord::Migration
  def change
    ShopifyApp.configure do |config|
      config.api_key = ENV['SHOPIFY_CLIENT_API_KEY']
      config.secret = ENV['SHOPIFY_CLIENT_API_SECRET']
      config.redirect_uri = ENV['SHOPIFY_REDIRECT_URI']
      config.scope = "read_orders, write_orders, read_products, write_products, read_customers, write_customers, read_themes, write_themes, read_fulfillments, write_fulfillments"
      config.embedded_app = true
    end

    Shop.find_each do |shop|
      shop.new_sess
      shop.orders.find_each do |order|
        begin
          shop_order = ShopifyAPI::Order.find(order.shopify_id)
        rescue
          sleep 2
          retry
        end
        puts "Processing: #{shop_order.id}"
        shop_order.line_items.each { |li| LineItem.from_shopify!(order, li) }
        puts "Done Processing: #{shop_order.id}"
      end
    end
  end
end
