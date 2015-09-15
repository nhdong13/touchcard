class WebhookController < AuthenticatedController
  before_filter :verify_webhook, only: [:order, :uninstall]

  def order
    domain = request.headers["X-Shopify-Shop-Domain"]
    head :ok
    # Start background process for a new order with id: params[:id]
  end

  def uninstall
    require 'slack_notify'
    head :ok
    shop = Shop.find_by(:shopify_id => params[:id])
    unless shop.nil?
      #delete shop
      shop.destroy

      #send notification to slack
      SlackNotify.uninstall(shop.domain)

      #respond to webhook again
      head :ok
    end
  end

  private

  def verify_webhook
    data = request.body.read.to_s
    hmac_header = request.headers['HTTP_X_SHOPIFY_HMAC_SHA256']
    digest  = OpenSSL::Digest::Digest.new('sha256')
    calculated_hmac = Base64.encode64(OpenSSL::HMAC.digest(digest, Touchcard::Application.config.shopify.secret, data)).strip
    unless calculated_hmac == hmac_header
      head :unauthorized
    end
    request.body.rewind
  end
end
