class CustomerMailer < ApplicationMailer
  def card_arrived_notification(postcard)
    shop = postcard.card_order.shop
    customer = postcard.customer
    @shop_name = shop.name
    @customer_name = customer.first_name
    mail to: customer.email, subject: "You've got a Postcard from #{@shop_name}!"
  end

  def send_coupon_expiration_notification(postcard)
    return "Cupon is not set" if postcard.discount_code.blank? || postcard.discount_exp.blank?
    return "Cupon expired!" if (postcard.discount_exp > Time.now and postcard.discount_pct > 0)

    card_order = postcard.card_order
    customer = postcard.customer
    @shop = card_order.shop
    @customer_name = customer.first_name
    @coupon_code = postcard.discount_code
    @coupon_value = "#{postcard.discount_pct}% OFF"

    mail to: customer.email, subject: "Coupon from #{@shop.name}!"
  end
end
