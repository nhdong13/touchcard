class InitializeSendingPostcardProcess
  def self.start shop, campaign
    campaign.update(enabled: true)
    SendingPostcardJob.perform_later(shop, campaign)
  end
end