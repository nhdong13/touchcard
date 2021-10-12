class PreparePostcardJob < ActiveJob::Base
  queue_as :default

  def perform order_id
    order = Order.find(order_id)
    shop = order.shop
    errors = []
    errors.push("no customer") unless order.customer
    errors.push("no default address") unless order.customer&.default_address
    errors.push("no street in address") unless order.customer&.default_address&.address1&.present?
    # default_address = order.customer.default_address
    # international = default_address.country_code != "US"
    return if errors.present?
    post_sale_orders = shop.card_orders.where(enabled: true, type: "PostSaleOrder").sending
    post_sale_orders.each{|post_sale_order| post_sale_order.prepare_for_sending(order) }
  end

end
