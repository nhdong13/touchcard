Rails.application.routes.draw do

  # API routes
  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do
      resources :card_sides, only: [:show, :update]
      resources :shops, only: [:show, :update]
      resources :card_orders, only: [:index, :show, :create, :update]
      resources :postcards, only: [:index, :show, :create, :update]
      resources :charges, only: [:index, :show, :create, :update] do
        get 'activate', on: :collection
      end
      resources :shopify_customers, only: [:index]
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

  # Set root path
  root :to => 'home#index'

  # Shopify Engine
  mount ShopifyApp::Engine, at: '/'
end
