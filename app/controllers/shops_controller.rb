class ShopsController < AuthenticatedController
  before_action :current_shop

  def show
    @shop = Shop.find(params[:id])
  end

  def edit
    @shop = Shop.find(params[:id])
    @shop.new_sess
    @last_month = ShopifyAPI::Customer.where(:created_at_min => (Time.now - 1.month)).count
    @current = @shop.charge_amount || 0
  end

  def update
    @shop = Shop.find(params[:id])
    @shop.assign_attributes(shop_params)

    # Save which attributes are updated
    changed =  @shop.changed_attributes
    @shop.save!

    # Check if a billing attribute has been changed or not
    unless changed[:charge_amount] == nil
      redirect_to @shop.new_charge(shop_params[:charge_amount])
    else
      flash[:success] = "Shop setting updated"
      redirect_to root_url
    end
  end

  private

  def shop_params
    params.require(:shop).permit(
      :customer_pct,
      :charge_amount,
      :enabled,
      :international,
      :send_delay)
  end

  def current_shop
    @current_shop ||= Shop.find(session[:shopify])
  end
end
