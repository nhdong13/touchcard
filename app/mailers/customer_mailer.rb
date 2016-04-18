class CustomerMailer < ApplicationMailer
  def card_arrived_notification(postcard)
    shop = postcard.card_order.shop
    customer = postcard.customer
    @shop_name = shop.name
    @customer_name = customer.first_name
    mail to: customer.email, subject: "You've got a Postcard from #{@shop_name}!"
  end
end
