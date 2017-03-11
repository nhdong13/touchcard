class SessionsController < ApplicationController
  include ShopifyApp::SessionsConcern
  include ShopifyApp::LoginProtection
  # def return_address
  #   session.delete(:return_to) || '/app'
  # end
end
