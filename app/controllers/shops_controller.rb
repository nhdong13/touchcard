class ShopsController < AuthenticatedController
  before_action :current_shop

  def show
    @shop = Shop.find(params[:id])
  end

  def edit
    @shop = Shop.find(params[:id])
    if params.has_key?(:template)
      @template = params[:template]
    end
  end

  def update
    @shop = Shop.find(params[:id])
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
