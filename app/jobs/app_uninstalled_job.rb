require "slack_notify"

class AppUninstalledJob < ActiveJob::Base

  def perform(shop_domain:, webhook:)
    shop = Shop.find(domain: shop_domain)
    shop.subscriptions.each { |s| s.destroy }
    shop.update_attributes(credit: 0, uninstalled_at: Time.now)
    SlackNotify.uninstall(shop.domain)
  end
  
end
