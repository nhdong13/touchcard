class Subscription < ActiveRecord::Base
  belongs_to :plan
  belongs_to :shop

  validates :plan, :shop, :quantity, :shopify_id,
    :current_period_start, :current_period_end, presence: true
  validate :only_one_subscription

  def only_one_subscription
    return if shop.subscriptions.count == 0
    errors.add(:shop, "already has a subscription")
  end

  def on_stripe?
    stripe_id.present?
  end

  class << self
    def create(params)
      # TODO: error handling
      shop = Shop.find_by(id: params[:shop_id])
      plan = Plan.find_by(id: params[:plan_id])
      return super(params) unless shop && plan
      subscription = shop.stripe_customer.subscriptions.create(
        plan: plan.id,
        quantity: quantity
      )
      instance = super(params.merge(
        shopify_id: subscription.id,
        current_period_start: subscription.current_period_start,
        current_period_end: subscription.current_period_end
      ))
      subscription.delete unless instance.valid?
      instance
    end
  end

  def update_attributes(params)
    subscription = shop.stripe_customer.subscriptions.retrieve(shopify_id)
    params.each { |key, value| subscription.send(key + '=', value) }
    subscription.save
    # TODO handle failure of saving of subscription
    super(params)
  end

  def destroy
    subscription = shop.stripe_customer.subscriptions.retrieve(shopify_id)
    subscription.delete
    super
  end
end
