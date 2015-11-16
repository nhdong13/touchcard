require 'customer_check'

class Api::V1::ShopifyCustomersController < API::BaseController
  def count
    @count = get_customer_number(@current_shop,
      params[:created_after],
      params[:created_before])
    render json: @count
  end
end
