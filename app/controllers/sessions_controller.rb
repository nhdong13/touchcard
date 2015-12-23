class SessionsController < ApplicationController
  include ShopifyApp::SessionsController
  def return_address
    session.delete(:return_to) || '/app'
  end
end
