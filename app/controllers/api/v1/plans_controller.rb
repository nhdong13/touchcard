class API::V1::PlansController < API::BaseController

  def index
    @current_shop.get_last_month
    render json: @current_shop, serializer: ShopSerializer
  end
end
