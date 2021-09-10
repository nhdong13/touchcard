class OrdersFulfilledJob < ActiveJob::Base
  def perform(arg)
    webhook = arg[:webhook]
    order = Order.find_by(shopify_id: webhook["id"])
    order.update!(fulfillment_status: "fulfilled") if order.present?
  end
end
