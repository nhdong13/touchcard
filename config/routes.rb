Rails.application.routes.draw do
  # Shopify Engine
  mount ShopifyApp::Engine, at: '/'

  root 'automations#index' # See comments in controller

  # API routes
  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do
      get 'sign', to: 'aws#sign'
      resources :card_sides, only: [:show, :update, :create]
      resources :filters, only: [:show, :update, :destroy, :create]
      resources :shops, only: [:show, :update] do
        collection { get :current }
      end
      resources :card_orders, only: [:index, :show, :create, :update, :destroy]
      resources :postcards, only: [:index, :show, :create, :update] do
        patch 'cancel', on: :member
      end
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

  # Shopify webhook routes
  post '/new_order',  to:   'shopify_app/webhooks#receive', defaults: { type: 'orders_create' }
  post '/uninstall',  to:   'shopify_app/webhooks#receive', defaults: { type: 'app_uninstalled' }

  # HTML Routes for Card Templates
  resources :card_orders, only: [:update, :create, :destroy]

  # DFL: Need this for destroy action to work
  resources :post_sale_orders, only: [:destroy]

  # DFL: Need this for create / update actions to work. (Can probably do this better)
  resources :post_sale_orders, :controller => "card_orders", :type => "PostSaleOrder"


  # Routes for Admins
  devise_for :admin_users, ActiveAdmin::Devise.config
  get '/admin' => 'admin/shops#index'
  ActiveAdmin.routes(self)

  # # Routes for updating scope
  get '/update_scope_prompt', to: 'root#update_scope_prompt'
  post '/update_scope_redirect', to: 'root#update_scope_redirect'

  get 'faq', to: 'faq#index'
  resources :dashboard, only: [:index] do
    patch 'cancel_postcard', on: :member
  end

  resource :subscription

  resources :automations, only: [:index, :show, :edit, :update] do
    # get 'select_type', :on => :collection
  end

  # Routes for AWS Controller (to sign S3 uploads)
  get '/aws/sign', to: 'aws#sign'

  if Rails.env.development?
    get '/lob_debug' => 'lob_api#debug'
  end

end
