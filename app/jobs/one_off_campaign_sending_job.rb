class OneOffCampaignSendingJob < ActiveJob::Base
  queue_as :default

  def perform campaign_id
    campaign = CardOrder.find(campaign_id)
    shop = campaign.shop
    shop.orders.find_each do |order|
      campaign.prepare_for_sending(order)
    end
  end

end
