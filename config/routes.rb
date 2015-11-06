Rails.application.routes.draw do

  # API routes
  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do
      resources :shops, only: [:show, :edit, :update]
      resources :card_templates, only: [:index, :show, :new, :create, :edit, :update, :bulk_send]
      resources :post_sale_templates, :controller => "card_templates", :type => "PostSaleTemplate", only: [:index, :show, :new, :create, :edit, :update]
      resources :bulk_templates,      :controller => "card_templates", :type => "BulkTemplate", only: [:index, :show, :new, :create, :edit, :update]
      resources :postcards, only: [:index, :show, :new, :create, :edit, :update]
      resources :charges, only: [:index, :show, :new, :create]

      # Routes for home
      get 'home/dashboard'
      get 'home/support'
    end
  end

  # Routes for charge callbacks
  get 'charge/activate'

  # Webhook routes
  post '/new_order',  to:   'webhook#new_order'
  post '/uninstall',  to:   'webhook#uninstall'

  # Routes for Admins
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  ######### Below is old ##########

  # Routes for Shops
  resources :shops

  # Routes for Card Templates
  resources :card_templates do
    get 'style_switch', :on => :member
    get 'image_remove', :on => :member
    post 'coupon_confirm', :on => :member
  end

  resources :postsale_templates,  :controller => "card_templates", :type => "PostsaleTemplate"
  resources :bulk_templates,      :controller => "card_templates", :type => "BulkTemplate"

  # Routes for Cards
  resources :postcards



  # Support page
  get '/support',   to: 'home#support'

  # Set root path
  root :to => 'home#index'

  # Shopify Engine
  mount ShopifyApp::Engine, at: '/'
end
