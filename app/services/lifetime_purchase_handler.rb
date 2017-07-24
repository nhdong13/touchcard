class LifetimePurchaseHandler
  attr_reader :shop

  def initialize(shop)
    @shop = shop
  end

  def call
    return unless activate_session
    pages = (customers_count / 250.0).ceil
    card = shop.card_orders.find_by(enabled: true, type_name: "Lifetime Purchase")
    customers = []
    1.upto(pages) do |page|
      customers << ShopifyAPI::Customer.find(:all, params: { page: page, limit: 250 })
    end
    customers.flatten.each do |customer|
      next if has_lifetime_postcard(customer)
      total_spent = ShopifyAPI::Customer.where(email: customer.email).first.total_spent
      send_lifetime_postcard(customer, card) if earns_lifetime_revard(total_spent)
    end
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

  def customers_count
    ShopifyAPI::Customer.count
  end

  def send_lifetime_postcard(customer, card)
    postcard = Postcard.new(
      customer: customer.id,
      card_order: card,
      send_date: card.send_date,
      paid: false)
    postcard.pay.save if shop.sending_active? && shop.can_afford_postcard?
  end

  # change name
  def earns_lifetime_revard(amount)
    amount.to_i >= 400 #change this to constant
  end

  def has_lifetime_postcard(customer)
    Postcard.joins(:card_order).where(card_orders: { type_name: "Lifetime Purchase" }, customer_id: customer.id).count > 1
  end
end
