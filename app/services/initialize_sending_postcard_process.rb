class InitializeSendingPostcardProcess
  def self.start shop, campaign
    campaign.update(enabled: true)
    FetchHistoryOrdersJob.perform_now(shop, shop.post_sale_orders.last.send_delay, campaign)
  end
end