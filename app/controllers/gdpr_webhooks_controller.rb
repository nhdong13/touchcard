class GdprWebhooksController < ActionController::Base # ApplicationController

  def customers_redact
    head :ok # this is done up front to prevent timeouts

    redact_request = GdprCustomersRedact.new(
        shop_shopify_id: params[:shop_id],
        shop_domain: params[:shop_domain],
        customer_shopify_id: params.dig(:customer, :id),
        customer_email: params.dig(:customer, :email),
        customer_phone: params.dig(:customer, :phone),
        orders_to_redact: params[:orders_to_redact]
    )
    redact_request.save!
  end

end
