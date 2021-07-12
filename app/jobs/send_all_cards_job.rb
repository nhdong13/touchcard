class SendAllCardsJob < ActiveJob::Base
  queue_as :default

  def perform shop, campaign
    return unless (campaign.scheduled? || campaign.sending?)
    campaign.sending!
    campaign.save!
    result = Postcard.send_all
    if result[:card_sent_amount] < result[:total_card]
      campaign.error!
    else
      campaign.sent!
    end
    campaign.save!

    # After finish job => checking if this campaign is satisfy conditions to stop
    # Conditions to stop:
    #   + Reach end date
    # NOTE: one-off campaign only do one
    return if reach_end_date(campaign) || campaign.one_off?

    # FetchHistoryOrdersJob.set(wait: 1.day).perform_later(shop, shop.post_sale_orders.last.send_delay, campaign)
  end

  private

    def reach_end_date campaign
      return false if campaign.send_continuously

      Time.now >= campaign.send_date_end
    end
end