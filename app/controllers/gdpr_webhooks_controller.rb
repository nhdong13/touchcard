class GdprWebhooksController < ShopifyApp::WebhooksController
  # skip_before_action :verify_request, unless: "Rails.env.production?"  # For testing webhooks locally

  def customers_data_request
    head :ok

    redact_request = GdprCustomersDataRequest.new(
        shop_shopify_id: params[:shop_id],
        shop_domain: params[:shop_domain],
        customer_shopify_id: params.dig(:customer, :id),
        customer_email: params.dig(:customer, :email),
        customer_phone: params.dig(:customer, :phone),
        orders_requested: params[:orders_requested]
    )
    redact_request.save!
  end

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

  def shop_redact
    head :ok

    redact_request = GdprShopRedact.new(
      shop_shopify_id: params[:shop_id],
      shop_domain: params[:shop_domain]
    )
    redact_request.save!
  end

end
