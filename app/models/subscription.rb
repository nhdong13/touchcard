class Subscription < ActiveRecord::Base
  belongs_to :plan
  belongs_to :shop

  validates :plan, :shop, :quantity, :stripe_id,
    :current_period_start, :current_period_end, presence: true

  # TODO validate only one subscription

  def on_stripe?
    stripe_id.present?
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
        quantity: params[:quantity]
      )
      logger.debug(subscription.current_period_start)
      logger.debug(Time.at(subscription.current_period_start))
      instance = super(params.merge(
        stripe_id: subscription.id,
        current_period_start: Time.at(subscription.current_period_start),
        current_period_end: Time.at(subscription.current_period_end)
      ))
      subscription.delete unless instance.valid?
      instance
    end
  end

  def update_attributes(params)
    subscription = shop.stripe_customer.subscriptions.retrieve(stripe_id)
    params.each { |key, value| subscription.send(key + '=', value) }
    subscription.save
    # TODO handle failure of saving of subscription
    super(params)
  end

  def destroy
    subscription = shop.stripe_customer.subscriptions.retrieve(stripe_id)
    subscription.delete
    super
  end
end
