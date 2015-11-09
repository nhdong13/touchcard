class API::V1::PlansController < API::BaseController

  def index
    @current_shop.get_last_month
    render json: { plans:  (0..4).map { |i|  { amount: @current_shop.last_month * i * 0.25 } } }
  end
end
