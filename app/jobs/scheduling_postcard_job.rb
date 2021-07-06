class SchedulingPostcardJob < ActiveJob::Base
  queue_as :default

  def perform campaign
    return unless campaign.processing?
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