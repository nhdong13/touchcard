class Subscription < ApplicationRecord
  belongs_to :plan
  belongs_to :shop

  attr_accessor :coupon

  validates :plan, :shop, :quantity, :stripe_id,
    :current_period_start, :current_period_end, presence: true
  validate :only_one_subscription

  before_save :set_subscription_value

  def set_subscription_value
    self.value = quantity * plan.amount.to_f / 100
  end

  def only_one_subscription
    return if shop.subscriptions.count == 0 || persisted?
    errors.add(:shop, "already has a subscription")
  end

  def on_stripe?
    stripe_id.present?
  end

  def change_quantity(new_quantity)

    # TODO: Make sure payment is current + upgrade quantity charge succeeded before adding
    # https://stripe.com/docs/billing/invoices/subscription#generating-invoices
    # or
    # https://stripe.com/docs/billing/invoices/one-off
    # TODO: At a minimum - make sure `stripe_customer.delinquent` is false

    return true if new_quantity == quantity
    delta_quantity = new_quantity - quantity
    old_quantity = quantity
    downgrade = new_quantity < quantity
    # TODO assertion test that new_quantity - credits_used > 0
    # TODO error handling on shop failure
    subscription = shop.stripe_customer.subscriptions.retrieve(stripe_id)
    subscription.quantity = new_quantity
    subscription.proration_behavior = "none"
    subscription.save
    update(quantity: new_quantity, stripe_id: subscription.id)
    # don't need to do anything for downgrade as the billing won't change till
    # next month
    return true if downgrade
    # if upgrading we want to immediately upgrade their credits by using a
    # one off charge for the delta credits between the two quantities
    # essentially they're buying extra credits for the month
    Stripe::InvoiceItem.create({
      customer: shop.stripe_customer.id,
      amount: delta_quantity * plan.amount,
      currency: "usd",
      description: "Plan upgrade from #{old_quantity} cards to #{new_quantity} cards adding #{delta_quantity} cards for this month"
    })
    shop.update(credit: shop.credit + delta_quantity * (Plan.last.amount.to_f / 100))
  end

  def change_quantity_by_credit(credit)
    new_quantity = (credit * 100 / Plan.last.amount).to_i
    change_quantity(new_quantity)
  end

  # Update subscription date to match the stripe dates
  def change_subscription_dates
    subscription = shop.stripe_customer.subscriptions.retrieve(stripe_id)
    return if subscription.blank?
    update(
      current_period_start: Time.at(subscription.current_period_start),
      current_period_end:   Time.at(subscription.current_period_end)
    )
  end

  class << self
    def create(params)
      # TODO: error handling
      shop = params[:shop] || Shop.find_by(id: params[:shop_id])
      plan = params[:plan] || Plan.find_by(id: params[:plan_id])
      # TODO return a better error it will currently show all the missing stripe fields too
      return super(params) unless shop && plan
      return super(params) unless shop.stripe_customer.present?
      subscription = shop.stripe_customer.subscriptions.create(
        plan: plan.stripe_plan_id || '1',
        quantity: params[:quantity],
        coupon: params[:coupon]
      )
      instance = super(params.merge(
        stripe_id: subscription.id,
        current_period_start: Time.at(subscription.current_period_start),
        current_period_end: Time.at(subscription.current_period_end)
      ))
      subscription.delete unless instance.valid?
      ShopSubscribedJob.perform_later(shop) if instance.valid? # Update external APIs (ie: email list)
      instance
    end
  end

  def destroy
    begin
      shop.stripe_customer.subscriptions.retrieve(stripe_id)&.delete if shop.stripe_customer
    rescue => e
      nil
    end
    super
  end

  # necessary for the active admin
  def display_name
    self.id
  end

  def change_plan plan_id
    Stripe::Subscription.update(stripe_id, {plan: plan_id})
  end
end
