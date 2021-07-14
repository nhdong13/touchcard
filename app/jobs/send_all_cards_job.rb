class SendAllCardsJob < ActiveJob::Base
  queue_as :default

  after_perform do |job|
    # After finish job => checking if this campaign is satisfy conditions to stop
    # Conditions to stop:
    #   + Reach end date
    # NOTE: one-off campaign only do one

    # job.arguments[0] => shop instance
    # job.arguments[1] => card order instance
    unless (reach_end_date(job.arguments[1]) || job.arguments[1].one_off? || !job.arguments[1].enabled)
      FetchHistoryOrdersJob.set(wait: 1.day).perform_later(job.arguments[0], job.arguments[0].post_sale_orders.last.send_delay, job.arguments[1])
    end
  end

  def perform shop, campaign
    campaign.sending!
    campaign.save!
    result = Postcard.send_all
    if result[:card_sent_amount] < result[:total_card]
      campaign.error!
    else
      campaign.sent!
    end
    campaign.save!
  end

  private

    def reach_end_date campaign
      return false if campaign.send_continuously

      Time.now >= campaign.send_date_end
    end
end