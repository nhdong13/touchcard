class StripeEvent < ActiveRecord::Base
  validates :stripe_id, presence: true
  validates :status, inclusion: { in: ['processing', 'processed'] }
end
