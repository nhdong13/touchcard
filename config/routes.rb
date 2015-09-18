Rails.application.routes.draw do

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  # Routes for Shops
  resources :shops

  # Routes for Master Cards
  resources :master_cards

  # Routes for Cards
  resources :cards

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
