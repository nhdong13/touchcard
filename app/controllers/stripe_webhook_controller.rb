class StripeWebhookController < ActionController::Base
  skip_before_action :verify_authenticity_token
  before_action :set_stripe_event, only: :create

  # webhook called anytime new charge is made on stripe
  def hook
    head :ok # this is done up front to prevent timouts
    @db_event.status = "processed"
    return unless @stripe_event.type == "invoice.payment_succeeded"
    # TODO: in future it may make more sense to double check that the
    #       subscription is the one that is desired
    shop = Shop.find_by(stripe_customer_id: @stripe_event.data.object.customer)
    shop.top_up

    stripe_subscription = Stripe::Subscription.find(@stripe_event.data.object.subscription)
    unless shop.subscriptions.blank?
      shop.subscriptions.first.change_subscription_dates(stripe_subscription)
    end

    @db_event.save!
  end

  private

  def set_stripe_event
    # already processed
    return head :ok if StripeEvent.find_by(stripe_id: params[:id])
    @stripe_event = Stripe::Event.retrieve(params[:id])
    head :not_found unless @stripe_event
    @db_event = StripeEvent.create!(
      status: "processing",
      stripe_id: @stripe_event.id)
  end
end
