class API::V1::ShopifyCustomersController < BaseApiController

  def shopify_customers
    require 'customer_check'
    @count = get_customer_number(@current_shop, params[:start_date], params[:end_date])

    render json: @count, serializer: ShopifyCustomerSerializer
  end
end
