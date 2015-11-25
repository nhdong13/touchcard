class Api::V1::ShopsController < Api::BaseController
  before_action :set_shop, only: [:show, :update]
  def show
    render json: @shop, serializer: ShopSerializer
  end

  def update
    if shopify_token.present?
      success = @shop.create_stripe_customer(shopify_token)
      return render_validation_errors(@shop)
    end
    success = @shop.update_attributes(shop_params)
    return render_validation_errors unless success
    render json: @shop, serializer: ShopSerializer
  end

  def current
    render json: @current_shop, serializer: ShopSerializer
  end

  private

  def set_shop
    @shop = @current_shop
    render_authorization_error unless params[:id] == @shop.id
  end

  def shop_params
    params.require(:shop).permit(:charge_amount)
  end

  def shopify_token
    params.require(:shop)[:shopify_token]
  end
end