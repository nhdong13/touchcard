class API::V1::ShopifyCustomersController < API::BaseController

  def index
    require 'customer_check'
    @count = get_customer_number(@current_shop, params[:start_date], params[:end_date])

    render json: @count
  end

end
