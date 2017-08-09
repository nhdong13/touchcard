class BaseController < ShopifyApp::AuthenticatedController
  before_action :require_auth

  def require_auth
    if session[:shopify].nil?
      render_authorization_error
    else
      @current_shop ||= Shop.find(session[:shopify])
      @current_shop.update_attributes(last_login_at: Time.now, uninstalled_at: nil)
    end
  end

  def render_authorization_error
    render json: { errors: "Forbidden"}, status: 401
  end
end
