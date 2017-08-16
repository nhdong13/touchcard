class SubscriptionsController < BaseController
  def new
    @subscription = Subscription.new
  end

  def create
    plan = Plan.first
    shop = @current_shop
    quantity = permited_params[:quantity]
    shop.create_stripe_customer(stripe_token)
    subscription = Subscription.create(shop: shop, plan: plan, quantity: quantity)
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
