class SchedulingPostcardJob < ActiveJob::Base
  queue_as :default

  before_enqueue do |job|
    # job.arguments[1] => card order instance
    throw :abort if (job.arguments[1].archived || job.arguments[1].complete?)
  end

  after_perform do |job|
    # job.arguments[0] => shop instance
    # job.arguments[1] => card order instance
    if Time.now.beginning_of_day >= job.arguments[1].send_date_start
      SendAllCardsJob.set(wait: 1.minutes).perform_later(job.arguments[0], job.arguments[1]) unless job.arguments[1].archived
    else
      FetchHistoryOrdersJob.set(wait: campaign.enabled? ? 1.day : 1.minutes).perform_later(job.arguments[0], job.arguments[0].post_sale_orders.last.send_delay, job.arguments[1])
    end
  end

  def perform shop, campaign
    return unless (campaign.enabled? &&
      (campaign.processing? || campaign.scheduled?) &&
      !campaign.archived)
    # begin

    result = true
    # Get postcard paid
    campaign.postcards.find_each do |postcard|
      result = PaymentService.pay_postcard_for_campaign_monthly campaign.shop, campaign, postcard
      break unless result
    end
    campaign.scheduled! if result

    # rescue
    #   campaign.error!
    # end

    campaign.save

  end
end