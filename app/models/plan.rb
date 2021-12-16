class Plan < ApplicationRecord

  validates :currency, :name, :interval, :interval_count, presence: true
  validates :interval, inclusion: { in: ["day", "week", "month", "year"] }
  after_initialize :ensure_defaults

  def ensure_defaults
    return if persisted?
    self.interval ||= "month"
    self.name ||= "#{helpers.number_to_currency(amount/100.0)}/#{interval}" if amount
    self.interval_count ||= 1
    self.currency ||= 'usd'
    self.on_stripe = false if self.on_stripe.nil?
  end

  def submit product
    fail "can't submit plan unless record persisted" unless persisted?
    fail "plan already on stripe" if on_stripe?
    plan = Stripe::Plan.create(
      amount: amount,
      interval: interval,
      currency: currency,
      # id: id,
      interval_count: interval_count,
      trial_period_days: trial_period_days,
      statement_descriptor: statement_descriptor,
      product: product
    )
    update(on_stripe: true, stripe_plan_id: plan.id)
  end

  def helpers
    ActionController::Base.helpers
  end

  def self.current
    Plan.find_by(amount: 89)
  end
end
