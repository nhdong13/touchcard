=begin
  This active job is used to fix the error
  Campaigns with no specified end date (ongoing) or didn't reached their end date
  should not be able to enter complete status

  This error could happen when the sending process and the status logic changed
  Some campaign can be stuck at complete status or processing status

  If this error don't happen anymore in the future, get rid of this
=end
class HandlingErrorCampaignCompleteJob < ActiveJob::Base
  queue_as :default

  def perform shop
    shop.card_orders.where(campaign_status: [:processing, :scheduled, :sending]).find_each do |c|
      campaign_global_id = c.to_global_id.to_s
      if Delayed::Job.exists?(["handler SIMILAR TO ?", "%#{campaign_global_id}%"])
        c.update(campaign_status: :error, enabled: false) if Delayed::Job.exists?(["last_error IS NOT NULL AND handler SIMILAR TO ?", "%#{campaign_global_id}%"])
      else
        c.update(campaign_status: :draft, enabled: false)
      end
    end

    CardOrder.where("shop_id = :shop_id AND campaign_status = :status AND ((send_continuously = FALSE AND send_date_end > :now) OR (send_continuously = TRUE))", {shop_id: shop.id,status: CardOrder.campaign_statuses[:complete], now: Time.now.beginning_of_day}).find_each do |c|
      c.processing!
      InitializeSendingPostcardProcess.start shop, c
    end

    CardOrder.where("shop_id = :shop_id AND campaign_status != :status AND send_continuously = FALSE AND send_date_end < :now", {shop_id: shop.id,status: CardOrder.campaign_statuses[:complete], now: Time.now.beginning_of_day}).find_each do |c|
      c.complete!
    end

  end
end