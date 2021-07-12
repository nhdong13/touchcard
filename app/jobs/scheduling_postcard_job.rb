class SchedulingPostcardJob < ActiveJob::Base
  queue_as :default

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

    # After perform job => Initialize next job
    SendAllCardsJob.set(wait: 1.minutes).perform_later(shop, campaign)
  end
end