ShopifyApp.configure do |config|
  config.application_name = "Touchcard" # Optional
  config.api_key = ENV['SHOPIFY_CLIENT_API_KEY']
  config.secret = ENV['SHOPIFY_CLIENT_API_SECRET']
  config.scope = "read_orders, read_products, read_customers, write_price_rules, write_marketing_events"
  config.embedded_app = true
end
