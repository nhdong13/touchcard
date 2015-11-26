require 'customer_check'

class Api::V1::ShopifyCustomersController < Api::BaseController
  def count
    @count = CustomerCheck.get_customer_number(@current_shop.id,
      Time.at(Integer(params[:created_after])/1000),
      Time.at(Integer(params[:created_before])/1000))
    render json: { meta: { count: @count} }, status: 200
  end
end
