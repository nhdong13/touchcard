class ProcessOrder
  attr_accessor :shop, :shopify_order, :logger

  def initialize(shop, shopify_order, logger)
    @shop = shop
    @shopify_order = shopify_order
    @logger = logger
  end

  def call
    # it's assumed that the check order function blocks any dulpicate actions
    # which can occur according to the shopfiy documentation
    order = Order.from_shopify!(shopify_order, shop)
    order.connect_to_postcard

    # we can't sent without address
    return logger.info "no default address" unless shopify_order.customer.respond_to?(:default_address)
    return logger.info "no default address" unless shopify_order.customer.default_address

    # Schedule to send lifetime purchase postcard if customer is eligible for lifetime revard
    ProcessLifetimePurchase.new(order.customer, shop).call

    # Only new customers recieve postcards at the moment
    return logger.info "Not a new customer" unless order.customer.new_customer?

    # Create a new card and schedule to send
    card = find_card
    return logger.info "Card not setup or enabeled" if card.nil?
    card.prepare_for_sending(order)
  end

  private

  def find_card
    shop.card_orders.find_by(enabled: true, type: "PostSaleOrder")
  end
end
