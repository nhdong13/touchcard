ShopifyApp.configure do |config|
  config.application_name = "Touchcard" # Optional
  config.api_key = ENV['SHOPIFY_CLIENT_API_KEY']
  config.secret = ENV['SHOPIFY_CLIENT_API_SECRET']
  config.old_secret = ""
  # When a write_XYZ permission exists, the read_XYZ permission is automatically included
  config.scope = "read_orders, read_products, read_customers, write_price_rules, write_marketing_events"
  # config.embedded_app = Rails.configuration.fullscreen_debug ? false : true
  config.embedded_app = true
  config.after_authenticate_job = false
  config.api_version = ""
  config.session_repository = Shop
  config.webhooks = [
    { topic: "orders/create", format: "json", fields: %w(id customer), address: "#{ENV['APP_URL']}/new_order" },
    { topic: "app/uninstalled", format: "json", fields: %w(id domain), address: "#{ENV['APP_URL']}/uninstall" }
  ]
end
