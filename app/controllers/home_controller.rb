class HomeController < ShopifyApp::AuthenticatedController
  def index
    if session[:update_scope]
      update_scopes_and_redirect_to_app_url
    else
      redirect_to app_url
    end
  end

  private

  def update_scopes_and_redirect_to_app_url
    shop = Shop.find(session[:shopify])
    scope = ShopifyApp.configuration.scope

    shop.update_scopes(scope)
    session[:update_scope] = nil
    redirect_to app_url
  end
end
