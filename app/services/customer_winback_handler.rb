class CustomerWinbackHandler
  attr_reader :customer, :shop

  def initialize(customer, shop)
    @customer = customer
    @shop = shop
  end

  def call
    return if card.nil? || winback_delay.nil? || customer.have_postcard_for_card(card)
    process_winback_postcard(card) if customer.eligible_for_winback_postcard(winback_start_date, winback_end_date)
  end

  def process_winback_postcard
    postcard = Postcard.new(
      customer: customer,
      card_order: card,
      send_date: Time.zone.now + 1.day, #set this to card.send_delay
      paid: false)
    if shop.pay(postcard)
      postcard.paid = true
      postcard.save
    end
  end

  def card
    shop.card_orders.find_by(enabled: true, type: "CustomerWinbackOrder")
  end

  def winback_delay
    card.winback_delay
  end

  def winback_end_date
    @winback_end_date ||= (Time.zone.now - winback_delay.days).to_date
  end

  def winback_start_date
    @winback_start_date ||= winback_end_date - 7.days
  end
end
