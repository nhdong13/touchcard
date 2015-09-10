Rails.application.routes.draw do

  # Routes for Cards
  get 'card/index'
  get 'card/new'
  get 'card/create'
  get 'card/show'
  get 'card/edit'
  get 'card/update'
  get 'card/destroy'

  # Webhook routes
  post '/new_product',  to:   'webhook#order'
  post '/uninstall',    to:   'webhook#uninstall'

  # Support page
  get '/support',   to: 'home#support'

  # Set root path
  root :to => 'home#index'

  # Shopify Engine
  mount ShopifyApp::Engine, at: '/'
end
