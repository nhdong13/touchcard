Rails.application.routes.draw do

  # API routes
  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do
      resources :shops, only: [:show, :update]
      resources :card_templates, only: [:index, :show, :create, :update]
      resources :post_sale_templates, :controller => "card_templates", :type => "PostSaleTemplate", only: [:index, :show, :create, :update]
      resources :bulk_templates,      :controller => "card_templates", :type => "BulkTemplate", only: [:index, :show, :create, :update]
      resources :postcards, only: [:index, :show, :create, :update]
      resources :charges, only: [:index, :show, :create, :update] do
        get 'activate', on: :collection
      end
      resources :shopify_customers, only: [:index]

      # Routes for home
      get 'home/dashboard'
      get 'home/support'
    end
  end

  # Webhook routes
  post '/new_order',  to:   'webhook#new_order'
  post '/uninstall',  to:   'webhook#uninstall'

  # HTML Routes for Card Templates
  resources :card_templates, only: [:update]

  # Routes for Admins
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  # Support page
  get '/support',   to: 'home#support'

  # Set root path
  root :to => 'home#index'

  # Shopify Engine
  mount ShopifyApp::Engine, at: '/'

######### Old HTML paths ##########

# # Routes for Shops
# resources :shops

# resources :card_templates, only: [:index, :show, :new, :create, :edit, :update, :destroy]

# resources :postsale_templates,  :controller => "card_templates", :type => "PostsaleTemplate"
# resources :bulk_templates,      :controller => "card_templates", :type => "BulkTemplate"

# # Routes for Cards
# resources :postcards

# # Routes for charge callbacks
# get 'charge/activate'
end
