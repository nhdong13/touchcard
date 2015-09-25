class ShopsController < AuthenticatedController
  before_action :current_shop

  def show
    @shop = Shop.find(params[:id])
  end

  def edit
    @shop = Shop.find(params[:id])
    @shop.new_sess
    @last_month = ShopifyAPI::Customer.where(:created_at_min => (Time.now - 1.month)).count
  end

  def update
    @shop = Shop.find(params[:id])
    @shop.update_attributes(shop_params)
    flash[:success] = "Setting updated"
    redirect_to root_url
  end

  private

  def shop_params
    params.require(:shop).permit(
      :enabled,
      :international,
      :send_delay)
  end

  def current_shop
    @current_shop ||= Shop.find(session[:shopify])
  end
end
