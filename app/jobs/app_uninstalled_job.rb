require "slack_notify"
require "active_campaign_logger"

class AppUninstalledJob < ActiveJob::Base

  def perform(params)
    shop_domain = params[:shop_domain]
    webhook = params[:webhook]
    shop = Shop.find_by(domain: shop_domain)
    shop.with_shopify_session do
      shop.subscriptions.each { |s| s.destroy }
      shop.update(credit: 0, uninstalled_at: Time.now)
      slack_msg = "A shop has uninstalled Touchcard: #{shop.domain}."
      SlackNotify.message(slack_msg) unless Rails.env.development?

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
