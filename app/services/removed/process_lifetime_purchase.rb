# TODO: Unused Automations Code
#
# class ProcessLifetimePurchase
#   attr_reader :customer, :shop
#
#   def initialize(customer, shop)
#     @customer = customer
#     @shop = shop
#   end
#
#   def call
#     return unless activate_session
#     return if card.nil? || card.lifetime_purchase_threshold.nil? || customer.have_postcard_for_card(card)
#     process_lifetime_postcard if customer_eligible_for_lifetime_reward
#   end
#
#   def activate_session
#     begin
#       session = ShopifyAPI::Session.new(
#         domain: shop.domain,
#         token: shop.token,
#         api_version: shop.api_version)
#       ShopifyAPI::Base.activate_session(session)
#     rescue
#       ShopifyAPI::Base.clear_session
#       warn "Can't open session for #{shop.domain}"
#     end
#   end
#
#   def process_lifetime_postcard
#     postcard = Postcard.new(
#       customer: customer,
#       card_order: card,
#       send_date: Time.zone.now + 1.day,
#       paid: false)
#     if shop.pay(postcard)
#       postcard.paid = true
#       postcard.save
#     end
#   end
#
#   def total_spent
#     ShopifyAPI::Customer.where(email: customer.email).first.total_spent.to_i
#   end
#
#   def card
#     shop.card_orders.find_by(type: "LifetimePurchaseOrder", enabled: true)
#   end
#
#   def customer_eligible_for_lifetime_reward
#     total_spent >= card.lifetime_purchase_threshold
#   end
# end
