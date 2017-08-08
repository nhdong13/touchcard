require "slack_notify"

class AppUninstalledJob < ApplicationJob

  def perform(shop_domain:, webhook:)
    shop = Shop.find_by(domain: shop_domain)
    shop.with_shopify_session do
      shop.subscriptions.each { |s| s.destroy }
      shop.update_attributes(credit: 0, uninstalled_at: Time.now)
      SlackNotify.uninstall(shop.domain)
    end
  end

end
