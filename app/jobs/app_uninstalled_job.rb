require "slack_notify"

class AppUninstalledJob < ActiveJob::Base

  def perform(shop_domain:, webhook:)
    shop = Shop.find_by(domain: shop_domain)
    shop.with_shopify_session do
      shop.subscriptions.each { |s| s.destroy }
      shop.update_attributes(credit: 0, uninstalled_at: Time.now)
      slack_msg = "A shop has uninstalled Touchcard: #{shop.domain}."
      SlackNotify.message(slack_msg)

      sync_params = {
          "email" => shop.email,
          "tags" => "uninstalled"
      }
      sync_params.reject!{ |k,v| v.nil?}  # remove keys with no value
      result = ActiveCampaign::client.contact_sync(sync_params)
      ActiveCampaignLogger.log(sync_params, result)
    end
  end

end
