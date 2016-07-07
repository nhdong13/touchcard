class CustomerMailer < ApplicationMailer
  def card_arrived_notification(postcard)
    shop = postcard.card_order.shop
    customer = postcard.customer
    @shop_name = shop.name
    @customer_name = customer.first_name
    mail to: customer.email, subject: "You've got a Postcard from #{@shop_name}!"
  end

  def send_coupon_expires(postcard)
    card_order = postcard.card_order
    customer = postcard.customer
    @shop_name = card_order.shop.name
    @customer_name = customer.first_name
    @coupon_code = postcard.discount_code
    @coupon_value = "#{card_order.discount_pct}% OFF"

    mail to: customer.email, subject: "Coupon from #{@shop_name}!"
  end
end
