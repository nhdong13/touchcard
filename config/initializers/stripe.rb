Rails.configuration.stripe = {
  :publishable_key => ENV['STRIPE_PUB'],
  :secret_key      => ENV['STRIPE_SECRET']
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]
Stripe.api_version = '2020-08-27'
