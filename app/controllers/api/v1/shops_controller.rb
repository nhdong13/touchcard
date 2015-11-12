class API::V1::ShopsController < API::BaseController
  before_action :set_shop, only: [:show, :update]
  def show
    render json: @shop, serializer: ShopSerializer
  end

  def update
    success = @shop.update_attributes(shop_params)
    return render_validation_errors unless success
    # Check if a billing attribute has been changed or not
    if @shop.charge_amount_changed?
      @shop.new_recurring_charge(shop_params[:charge_amount])
    end
    render json: @shop, serializer: ShopSerializer
  end

  private

  def set_shop
    @shop = @current_shop
    render_authorization_error unless params[:id] == @shop.id
  end

  def shop_params
    params.require(:shop).permit(
      :id,
      :token,
      :charge_amount,
      :customer_pct,
      :last_month)
  end

end
