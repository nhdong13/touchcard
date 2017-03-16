ShopifyApp.configure do |config|
  config.application_name = "Touchcard" # Optional
  config.api_key = ENV['SHOPIFY_CLIENT_API_KEY']
  config.secret = ENV['SHOPIFY_CLIENT_API_SECRET']
  config.scope = "read_orders, write_orders, read_products, write_products, read_customers, write_customers, read_themes, write_themes, read_fulfillments, write_fulfillments"
  config.embedded_app = true
  config.webhooks = [
    { topic: "orders/create", format: "json", fields: %w(id customer), address: "#{ENV['APP_URL']}/webhooks/orders_create" },
    { topic: "app/uninstalled", format: "json", fields: %w(id domain), address: "#{ENV['APP_URL']}/webhooks/app_uninstalled" }
  ]
end
