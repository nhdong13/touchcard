require "slack_notify"

class ShopSubscribedJob < ActiveJob::Base
  queue_as :default

  def perform(shop)

    sync_params = {
        "email" => shop.email,
        "p[#{ENV['AC_CUSTOMERS_LIST_ID']}]" => ENV['AC_CUSTOMERS_LIST_ID']
    }
    sync_params.reject!{ |k,v| v.nil?}  # remove keys with no value

    result = ActiveCampaign::client.contact_sync(sync_params)
    puts "ActiveCampaign Contact Sync\n#{sync_params}\n#{result}\n"
  end
end
