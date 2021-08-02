class SendAllCardsJob < ActiveJob::Base
  queue_as :default

  before_enqueue do |job|
    # job.arguments[1] => card order instance
    throw :abort if (job.arguments[1].archived || job.arguments[1].complete?)
  end

  # Migrate all old sending postcard logic to new one
  before_perform do |job|
    SendingPostcardJob.perform_later(job.arguments[0], job.arguments[1])
    throw :abort
  end

  after_perform do |job|
    # After finish job => checking if this campaign is satisfy conditions to stop
    # Conditions to stop:
    #   + Reach end date
    # NOTE: one-off campaign only do one

    # job.arguments[0] => shop instance
    # job.arguments[1] => card order instance
    if (job.arguments[1].enabled && job.arguments[1].sending?)
      unless (reach_end_date(job.arguments[1]) || job.arguments[1].one_off? || job.arguments[1].archived)
        FetchHistoryOrdersJob.set(wait: 1.day).perform_later(job.arguments[0], job.arguments[0].post_sale_orders.last.send_delay, job.arguments[1])
      else
        EnableDisableCampaignService.disable_campaign job.arguments[1], :complete, "#{job.arguments[1].campaign_name} is complete"
      end
    else
      FetchHistoryOrdersJob.set(wait: 1.minutes).perform_later(job.arguments[0], job.arguments[0].post_sale_orders.last.send_delay, job.arguments[1])
    end
  end

  def perform shop, campaign
    return unless (campaign.enabled? && (campaign.sending? || campaign.scheduled?) && !campaign.archived)
    campaign.sending!
    result = Postcard.send_all campaign.id
    Rails.logger.debug "There are error in sending process" if result[:card_sent_amount] < result[:total_card]
    campaign.save!
  end

  private

    def reach_end_date campaign
      return false if campaign.send_continuously

      Time.now.beginning_of_day >= campaign.send_date_end
    end
end