class SchedulingPostcardJob < ActiveJob::Base
  queue_as :default

  after_perform do |job|
    # job.arguments[0] => shop instance
    # job.arguments[1] => card order instance
    SendAllCardsJob.set(wait: 1.minutes).perform_later(job.arguments[0], job.arguments[1]) unless job.arguments[1].archived
  end

  def perform shop, campaign
    if campaign.out_of_credit?
      campaign.processing! if shop.credit > 0.0
    end

    return unless (campaign.enabled? &&
      (campaign.processing? || campaign.scheduled?) &&
      !campaign.archived)
    begin
      result = true
      # Get postcard paid
      campaign.postcards.find_each do |postcard|
        result = PaymentService.pay_postcard_for_campaign_monthly campaign.shop, campaign, postcard
        break unless result
      end
      campaign.scheduled! if result
    rescue
      campaign.error!
    end
    campaign.save

  end
end