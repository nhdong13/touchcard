class AuthenticatedController < ApplicationController
  before_action :login_again_if_different_shop
  before_action :set_current_shop
  around_filter :shopify_session
  layout ShopifyApp.configuration.embedded_app? ? 'embedded_app' : 'application'

  private

  def set_current_shop
    return unless session[:shopify]
    @current_shop ||= Shop.find(session[:shopify])
  end
end
