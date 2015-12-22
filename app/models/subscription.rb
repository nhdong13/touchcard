class Subscription < ActiveRecord::Base
  belongs_to :plan
  belongs_to :shop

  validates :plan, :shop, :quantity, :stripe_id,
    :current_period_start, :current_period_end, presence: true
  validate :only_one_subscription

  def only_one_subscription
    return if shop.subscriptions.count == 0 || persisted?
    errors.add(:shop, "already has a subscription")
  end

  def on_stripe?
    stripe_id.present?
  end

  def change_quantity(new_quantity)
    return true if new_quantity == quantity
    delta_quantity = new_quantity - quantity
    old_quantity = quantity
    downgrade = new_quantity < quantity
    # TODO assertion test that new_quantity - credits_used > 0
    # TODO error handling on shop failure
    subscription = shop.stripe_customer.subscriptions.retrieve(stripe_id)
    subscription.quantity = new_quantity
    subscription.prorate = false
    subscription.save
    update_attributes(quantity: new_quantity)
    # don't need to do anything for downgrade as the billing won't change till
    # next month
    return true if downgrade
    # if upgrading we want to immediately upgrade their credits by using a
    # one off charge for the delta credits between the two quantities
    # essentially they're buying extra credits for the month
    shop.stripe_customer.add_invoice_item(
      amount: delta_quantity * plan.amount,
      currency: "usd",
      description: "Plan upgrade from #{old_quantity} cards to #{new_quantity} cards adding #{delta_quantity} cards for this month")
    shop.update_attributes(credit: shop.credit + delta_quantity)
  end

  class << self
    def create(params)
      # TODO: error handling
      shop = params[:shop] || Shop.find_by(id: params[:shop_id])
      plan = params[:plan] || Plan.find_by(id: params[:plan_id])
      # TODO return a better error it will currently show all the missing stripe fields too
      return super(params) unless shop && plan
      subscription = shop.stripe_customer.subscriptions.create(
        plan: plan.id,
        quantity: params[:quantity])
      instance = super(params.merge(
        stripe_id: subscription.id,
        current_period_start: Time.at(subscription.current_period_start),
        current_period_end: Time.at(subscription.current_period_end)))
      subscription.delete unless instance.valid?
      instance
    end
  end

  def destroy
    subscription = shop.stripe_customer.subscriptions.retrieve(stripe_id)
    subscription.delete
    super
  end
end
