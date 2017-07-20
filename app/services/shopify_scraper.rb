class ShopifyScraper
  attr_reader :shop

  def initialize(shop)
    @shop = shop
  end

  def call
    return unless activate_session
    shop.customers.each do |customer|
      return unless orders_count(customer) > 0
      # implement this to check does customer already has postcard sent
      return if customer.has_postcard_sent?
      pages = (orders_count / 250.0).ceil
      1.upto(pages) |page|
        orders = ShopifyAPI::Order.find(:all, params: {
                                              customer_id: customer.customer.shopify_id,
                                              page: page,
                                              limit: 250 })
        orders.process_orders_for_winback_postcards
      end
    end
    num_pages = (customer_count)
    ShopifyAPI::Order
  end

  def activate_session
    begin
      session = ShopifyAPI::Session.new(shop.domain, shop.token)
      ShopifyAPI::Base.activate_session(session)
      orders_count
    rescue
      ShopifyAPI::Base.clear_session
      warn "Can't open session for #{shop.domain}"
    end
  end

  def orders_count(customer)
    ShopifyAPI::Customer.search(query: "#{customer.email}").first.orders_count
  end
end
