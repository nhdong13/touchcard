class SubscriptionsController < BaseController
  def new
    @shop = @current_shop
    @subscription = Subscription.new
  end

  def create
    # plan = Plan.first
    # shop = @current_shop
    # quantity = permited_params[:quantity]
    # shop.create_stripe_customer(stripe_token)
    # subscription = Subscription.create(shop: shop, plan: plan, quantity: quantity)

    # Amount in cents
    @amount = 500

    customer = Stripe::Customer.create(
        :email => params[:stripeEmail],
        :source  => params[:stripeToken]
    )

    charge = Stripe::Charge.create(
        :customer    => customer.id,
        :amount      => @amount,
        :description => 'Rails Stripe customer',
        :currency    => 'usd'
    )


  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to new_subscription_path
  end

  def edit
  end

  def update
  end

  private
  def permited_params
    params.permit(:token, :quantity)
  end
end
