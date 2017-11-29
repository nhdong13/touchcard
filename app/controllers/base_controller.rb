class BaseController < ShopifyApp::AuthenticatedController
  before_action :require_auth
  skip_around_action :shopify_session if Rails.configuration.fullscreen_debug

  def require_auth
    return @current_shop ||= Shop.last if Rails.configuration.fullscreen_debug
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
