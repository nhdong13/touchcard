Rails.application.routes.draw do

  # Routes for Shops
  resources :shops

  # Routes for Master Cards
  resources :master_cards do
    get 'template_switch', :on => :member
    get 'image_remove', :on => :member
    post 'coupon_confirm', :on => :member
  end

  # Routes for Cards
  resources :cards

  # Routes for Admin
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  # Routes for charges
  get 'charge/activate'

  # Webhook routes
  post '/new_order',  to:   'webhook#new_order'
  post '/uninstall',  to:   'webhook#uninstall'

  # Support page
  get '/support',   to: 'home#support'

  # Set root path
  root :to => 'home#index'

  # Shopify Engine
  mount ShopifyApp::Engine, at: '/'
end
