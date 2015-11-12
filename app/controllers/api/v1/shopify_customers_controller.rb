require 'customer_check'

class API::V1::ShopifyCustomersController < API::BaseController
  def index
    @count = get_customer_number(@current_shop,
      params[:start_date],
      params[:end_date])
    render json: @count
  end
end
