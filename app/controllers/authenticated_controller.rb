class AuthenticatedController < ApplicationController
  before_action :login_again_if_different_shop, only: [:second_login]
  around_action :shopify_session, only: [:index]
  layout ShopifyApp.configuration.embedded_app? ? "embedded_app" : "application"
end
