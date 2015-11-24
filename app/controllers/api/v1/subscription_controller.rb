class Api::V1::SubscriptionController < ApplicationController
  before_action :set_subscription, only: [:update, :show]
  def show
    render json: @subscription, serializer: SubscriptionSerializer
  end

  def create
    @subscription = Subscription.create(create_params)
    return render_validation_errors(@subscription) unless @subscription.valid?
    @current_shop.top_up
    render json: @subscription, serializer: SubscriptionSerializer
  end

  def update
    success = @subscription.update_attributes(update_params)
    return render_validation_errors(@subscription) unless success
    render json: @subscription, serializer: SubscriptionSerializer
  end

  def delete
    @subscription.destroy
    render json: {}
  end

  private
  def set_subscription
    @subscription = Subscription.find_by(id: params[:id])
    return render_not_found unless @subscription
    render_authorization_error unless @subscription.shop_id == @current_shop.id
  end

  def create_params
    update_params.merge(shop: @current_shop)
  end

  def update_params
    params.require(:subscription).permit(:quantity, :plan_id)
  end
end
