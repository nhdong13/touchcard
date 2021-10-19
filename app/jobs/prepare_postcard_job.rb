class PreparePostcardJob < ActiveJob::Base
  queue_as :default

  def perform order_id
    order = Order.find(order_id)
    shop = order.shop
    errors = []
    errors.push("no customer") unless order.customer
    errors.push("no default address") unless order.customer&.default_address
    errors.push("no first name in address") unless order.customer&.default_address&.first_name&.present?
    errors.push("no last name in address") unless order.customer&.default_address&.last_name&.present?
    errors.push("no street in address") unless order.customer&.default_address&.address1&.present?
    errors.push("no city in address") unless order.customer&.default_address&.city&.present?
    errors.push("no zip in address") unless order.customer&.default_address&.zip&.present?
    errors.push("no state in address") unless order.customer&.default_address&.province_code&.present?
    errors.push("no country in address") unless order.customer&.default_address&.country_code&.present?

    # default_address = order.customer.default_address
    # international = default_address.country_code != "US"
    return if errors.present?
    post_sale_orders = shop.card_orders.where(enabled: true, type: "PostSaleOrder").sending.automation
    post_sale_orders.each{|post_sale_order| post_sale_order.prepare_for_sending(order) }
  end

end
