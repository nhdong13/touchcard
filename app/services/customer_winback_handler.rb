class CustomerWinbackHandler
  # Call this from daily task
  attr_reader :shop

  def initialize(shop)
    @shop = shop
  end

  def call
    return unless activate_session
    pages = (customers_count / 250.0).ceil
    card = shop.card_orders.find_by(enabled: true, type_name: "Customer Winback")
    customers = []
    1.upto(pages) { |page| customers << ShopifyAPI::Customer.find(:all, params: { page: page, limit: 250 }) }
    customers.each do |customer|
      # maybe create ShopifyCustomer model since every method needs customer as arg
      next if orders_for_last_30days(customer) > 0
      # Fix logic here
      customer_id = customer.first.id
      if customer_has_postcard_created(customer_id)
        if sixty_day_orders(customer_id) > 0
          create_postcard if time_for_60days_postcard?
        end
      elsif sixty_day_orders(customer_id) < 0
        postcard = Postcard.new(
          customer: customer_id,
          card_order: card,
          send_date: card.send_date,
          paid: false)
        postcard.pay.save if shop.sending_active? && shop.can_afford_postcard?
      end
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

  def orders_for_last_30days(customer_id)
    @orders_for_last_30days ||= ShopifyAPI::Order.count(customer_id: "#{customer_id}", created_at_min: 1.month.ago.to_date)
  end

  def sixty_day_orders(customer_id)
    @sixty_day_orders ||= ShopifyAPI::Order.count(customer_id: "#{customer_id}", created_at_min: 2.month.ago.to_date)
  end

  def time_for_60days_postcard?
    # check that postcard last created postcard is created 30 days ago
    # customer_winback_postcard.first.created_at <=
  end

  def customer_has_postcard_created(customer)
    customer_winback_postcard.any?
  end

  def customer_winback_postcard(customer)
    Postcard.where("type_name = ? AND customer_id = ?", "Customer Winback", customer_id)
  end

end
