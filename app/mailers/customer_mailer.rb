class CustomerMailer < ApplicationMailer
  def card_arrived_notification(postcard)
    shop = postcard.card_order.shop
    customer = postcard.customer
    @shop_name = shop.name
    @customer_name = customer.first_name
    mail to: customer.email, subject: "You've got a Postcard from #{@shop_name}!"
  end

  def send_coupon_expiration_notification(postcard)

    # TODO: We should bail out if there is not discount coupon or expiration is in the past
    # if not ( postcard.discount_exp > Time.now and postcard.discount_pct > 0)

    card_order = postcard.card_order
    customer = postcard.customer
    @shop = card_order.shop
    @customer_name = customer.first_name
    @coupon_code = postcard.discount_code

    raise "Improve logic, see below"
    # TODO: Should store discount_pct with postcards:
    # @coupon_value = "#{postcard.discount_pct}% OFF"
    @coupon_value = "#{card_order.discount_pct}% OFF"

    mail to: customer.email, subject: "Coupon from #{@shop.name}!"
  end
end
