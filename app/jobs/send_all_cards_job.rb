class SendAllCardsJob < ActiveJob::Base
  queue_as :default

  def perform campaign
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
  end
end