require 'customer_check'

class Api::V1::ShopifyCustomersController < Api::BaseController
  def count
    @count = CustomerCheck.get_customer_number(@current_shop,
      Time.at(params[:created_after]),
      Time.at(params[:created_before]))
    render json: { meta: { count: @count} }, status: 200
  end
end
