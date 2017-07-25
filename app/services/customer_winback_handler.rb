class CustomerWinbackHandler
  attr_reader :customer, :shop

  def initialize(customer, shop)
    @customer = customer
    @shop = shop
  end

  def call
    card = shop.card_orders.where(enabled: true, type_name: "CustomerWinback")
    return if card.nil? || customer.have_winback_postcard_sent?(card)
    process_winback_postcard(card) if customer.eligible_for_winback_postcard(card.winback_delay)
  end

  def process_winback_postcard(card)
    Postcard.new(
      customer: customer,
      card_order: card,
      send_date: Time.zone.now + 1.day, #set this to card.send_delay
      paid: false)
    postcard.pay.save! if postcard.can_afford?
  end
end
