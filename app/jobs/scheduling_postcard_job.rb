class SchedulingPostcardJob < ActiveJob::Base
  queue_as :default

  def perform campaign
    begin
      # Get postcard paid
      campaign.postcards.each do |postcard|
        PaymentService.pay_postcard_for_campaign_monthly campaign.shop,campaign, postcard
      end
      campaign.scheduled!
    rescue
      campaign.error!
    end
    campaign.save
  end
end