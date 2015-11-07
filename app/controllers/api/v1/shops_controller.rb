class API::V1::ShopsController < BaseApiController

  def show
    render json: @current_shop, serializer: ShopSerializer
  end

  def edit
#   @current_shop = Shop.find_by(params[:id])
#   @current_shop.new_sess
#   @last_month = ShopifyAPI::Customer.where(:created_at_min => (Time.now - 1.month)).count
#   @current_shop.update_attribute(:last_month, @last_month)

#   render json: @current_shop, serializer: ShopSerializer
  end

  def update
    @shop = Shop.find(params[:id])
    @shop.assign_attributes(shop_params)

    # Save which attributes are updated
    changed =  @shop.changed_attributes
    @shop.save!

    # Check if a billing attribute has been changed or not
    unless changed[:charge_amount] == nil
      @shop.new_recurring_charge(shop_params[:charge_amount])
    end

    render json: @shop, serializer: ShopSerializer
  end

  private

  def shop_params
    params.require(:shop).permit(
      :charge_amount)
  end

end
