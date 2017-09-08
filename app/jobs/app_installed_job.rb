require "slack_notify"
require "active_campaign_logger"

class AppInstalledJob < ActiveJob::Base
  queue_as :default

  def perform(shop)

    size_tag = case shop.last_month
                 when 0...100 then "S"
                 when 100...500 then "M"
                 when 500...1500 then "L"
                 else "XL"
               end
    sync_params = {
        "email" => shop.email,
        "p[#{ENV['AC_INSTALLED_SHOP_LIST_ID']}]" => ENV['AC_INSTALLED_SHOP_LIST_ID'],
        "field[%STORE_URL%,0]" => shop.domain,
        "first_name" => (shop.owner.split(" ", 2).first if shop.owner),
        "last_name" => (shop.owner.split(" ", 2).last if shop.owner),
        "tags" => size_tag
    }
    sync_params.reject!{ |k,v| v.nil?}  # remove keys with no value

    result = ActiveCampaign::client.contact_sync(sync_params)
    ActiveCampaignLogger.log(sync_params, result)

    slack_message = "A new shop has installed Touchcard: #{shop.domain}\n" +
        "email: #{shop.email}\nowner: #{shop.owner}\n# new customers: #{shop.last_month}"
    SlackNotify.message(slack_message)
  end
end
