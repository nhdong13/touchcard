require "slack_notify"

class ShopUninstalledJob < ActiveJob::Base

  def perform(shop_domain:, webhook:)
    shop = Shop.find_by(domain: shop_domain)
    shop.with_shopify_session do
      shop.subscriptions.each { |s| s.destroy }
      shop.update_attributes(credit: 0, uninstalled_at: Time.now)
      slack_msg = "A shop has uninstalled Touchcard: #{shop.domain}."
      SlackNotify.message(slack_msg)
    end
  end

end
