class ProcessLifetimePurchase
  attr_reader :customer, :shop

  def initialize(customer, shop)
    @customer = customer
    @shop = shop
  end

  def call
    return unless activate_session
    return if card.nil? || card.lifetime_purchase_threshold.nil? || customer.have_postcard_for_card(card)
    process_lifetime_postcard if eligible_for_lifetime_revard
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

  def process_lifetime_postcard
    postcard = Postcard.new(
      customer: customer,
      card_order: card,
      send_date: Time.zone.now + 1.day,
      paid: false)
    postcard.pay.save if postcard.can_afford?
  end

  def total_spent
    ShopifyAPI::Customer.where(email: customer.email).first.total_spent.to_i
  end

  def card
    shop.card_orders.find_by(type: "LifetimePurchase", enabled: true)
  end

  def eligible_for_lifetime_revard
    total_spent >= card.lifetime_purchase_threshold
  end
end
