class SchedulingPostcardJob < ActiveJob::Base
  queue_as :default

  after_perform do |job|
    # job.arguments[0] => shop instance
    # job.arguments[1] => card order instance
    SendAllCardsJob.set(wait: 1.minutes).perform_later(job.arguments[0], job.arguments[1]) unless (job.arguments[1].error? || job.arguments[1].paused?)
  end

  def perform shop, campaign
    begin
      result = true
      # Get postcard paid
      campaign.postcards.find_each do |postcard|
        result = PaymentService.pay_postcard_for_campaign_monthly campaign.shop, campaign, postcard
        break if !result
      end
      campaign.scheduled! if result
    rescue
      campaign.error!
    end
    campaign.save

  end
end