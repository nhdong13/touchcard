Rails.application.routes.draw do

  root :to => 'root#index'
  # API routes
  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do
      get 'sign', to: 'aws#sign'
      resources :card_sides, only: [:show, :update]
      resources :shops, only: [:show, :update] do
        collection { get :current }
      end
      resources :card_orders, only: [:index, :show, :create, :update]
      resources :postcards, only: [:index, :show, :create, :update]
      resources :subscriptions, only: [:show, :create, :update]
      resources :plans, only: [:show, :index]
      # Switched to stripe this is not used for now
      # resources :charges, only: [:show, :create, :update] do
      #   get 'activate', on: :collection
      # end
      resources :shopify_customers, only: [] do
        collection { get :count }
      end
    end
  end

  # Webhook routes
  post '/new_order',  to:   'webhook#new_order'
  post '/uninstall',  to:   'webhook#uninstall'

  # HTML Routes for Card Templates
  resources :card_orders, only: [:update]

  # Routes for Admins
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  # Support page
  get '/support',   to: 'home#support'

  # Shopify Engine
  mount ShopifyApp::Engine, at: '/'
  get '/app' => 'root#app'
  get '/app/*path' => 'root#app'
end
