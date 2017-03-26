Rails.application.routes.draw do
  # API routes
  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do
      get 'sign', to: 'aws#sign'
      resources :card_sides, only: [:show, :update]
      resources :filters, only: [:show, :update, :destroy, :create]
      resources :shops, only: [:show, :update] do
        collection { get :current }
      end
      resources :card_orders, only: [:index, :show, :create, :update]
      resources :postcards, only: [:index, :show, :create, :update]
      resources :line_items, only: [:index, :show]
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
  # Stripe wobhook routes
  post '/stripe/events', to: 'stripe_webhook#hook'

  # HTML Routes for Card Templates
  resources :card_orders, only: [:update]

  # Routes for Admins
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  # Support page
  get '/support',   to: 'home#support'

  # Shopify Engine
  root :to => 'home#index'
  mount ShopifyApp::Engine, at: '/'
  get '/app' => 'root#app'
  get '/app/*path' => 'root#app'
end
