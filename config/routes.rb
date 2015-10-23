Rails.application.routes.draw do

  # Routes for Shops
  resources :shops

  # Routes for Card Templates
  resources :card_templates do
    get 'template_switch', :on => :member
    get 'image_remove', :on => :member
    post 'coupon_confirm', :on => :member
  end

  # Routes for Cards
  resources :postcards

  # Routes for Admins
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
