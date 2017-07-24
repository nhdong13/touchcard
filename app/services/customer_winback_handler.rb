class CustomerWinbackHandler
  attr_reader :customer

  def initialize(customer)
    @customer = customer
  end

  def call
    sent_winback_postcards_number = get_sent_winback_postcards_number(customer)
    num_of_days_for_sending_postcard = sent_winback_postcards_number + 1 * 30
    last_order_time = customer.orders.last.created_at # order this by created_at
    days_from_last_order = calculate_days_from_last_order(last_order_time)

    send_winback_postcard if days_from_last_order > num_of_days_for_sending_postcard
  end

  def send_winback_postcard
    shop = customer.shop
    card = shop.card_orders.where(enabled: true, type_name: "CustomerWinback")
    Postcard.new(
      customer: customer,
      card_order: card,
      send_date: card.send_date,
      paid: false)
    postcard.pay.save! if shop.sending_active? && shop.can_afford_postcard?
  end

  def calculate_days_from_last_order(last_order_time)
    start_date = Date.parse(Time.zone.now.to_s)
    end_date = Date.parse(last_order_time.to_s)
    (start_date - end_date).to_i
  end

  def get_sent_winback_postcards_number(customer)
    Postcard.joins(:card_order).where(card_orders: { type: "Customer Winback" }, customer_id: customer.id).count
  end
end
