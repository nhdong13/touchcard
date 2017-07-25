class ProcessLifetimePurchase
  attr_reader :customer, :shop

  def initialize(customer, shop)
    @customer = customer
    @shop = shop
  end

  def call
    return unless activate_session
    card = shop.card_orders.find_by(type_name: "LifetimePurchase", enabled: true)
    return if card.nil? || customer_have_lifetime_purchase_postcard?(card) 
    total_spent = ShopifyAPI::Customer.where(email: customer.email).first.total_spent
    process_lifetime_postcard(customer, card) if customer_eligible_for_lifetime_revard(total_spent)
  end

  def activate_session
    begin
      session = ShopifyAPI::Session.new(shop.domain, shop.token)
      ShopifyAPI::Base.activate_session(session)
    rescue
      ShopifyAPI::Base.clear_session
      warn "Can't open session for #{shop.domain}"
    end
  end

  def process_lifetime_postcard(customer, card)
    postcard = Postcard.new(
      customer: customer.id,
      card_order: card,
      send_date: Time.zone.now + 1.day,
      paid: false)
    postcard.pay.save if postcard.can_afford?
  end

  # change name
  def customer_eligible_for_lifetime_revard(amount)
    amount.to_i >= 400 #change this to constant
  end

  def customer_have_lifetime_purchase_postcard?(card)
    Postcard.joins(:card_order)
      .where(card_orders: { type_name: "Lifetime Purchase" }, customer_id: customer.id, card_order_id: card.id).any?
  end
end
