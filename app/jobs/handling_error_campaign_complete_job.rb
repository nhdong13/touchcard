=begin
  This active job is used to fix the error
  Campaigns with no specified end date (ongoing) or didn't reached their end date
  should not be able to enter complete status

  This error could happen when the sending process and the status logic changed
  Some campaign can be stuck at complete status

  If this error don't happen anymore in the future, get rid of this
=end
class HandlingErrorCampaignCompleteJob < ActiveJob::Base
  queue_as :default

  def perform shop
    CardOrder.where(shop_id: shop.id, campaign_status: :complete, send_continuously: true).find_each do |c|
      c.processing!
      InitializeSendingPostcardProcess.start shop, c
    end
    CardOrder.where("shop_id = :shop_id AND campaign_status = :status AND send_continuously = FALSE AND send_date_end > :now", {shop_id: shop.id,status: CardOrder.campaign_statuses[:complete], now: Time.now.beginning_of_day}).find_each do |c|
      c.processing!
      InitializeSendingPostcardProcess.start shop, c
    end
  end
end