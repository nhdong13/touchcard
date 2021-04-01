class SendAllHistoryCardsJob < ActiveJob::Base
  queue_as :default

  def perform(shop)
    Postcard.send_all_history_cards(shop)
  end
end