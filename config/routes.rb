Rails.application.routes.draw do
  # Shopify Engine
  mount ShopifyApp::Engine, at: '/'

  root 'automations#index' # See comments in controller

  # Stripe wobhook routes
  post '/stripe/events', to: 'stripe_webhook#hook'

  # Shopify webhook routes
  post '/new_order',  to:   'shopify_app/webhooks#receive', defaults: { type: 'orders_create' }
  post '/uninstall',  to:   'shopify_app/webhooks#receive', defaults: { type: 'app_uninstalled' }

  # GDPR webhooks
  post 'gdpr/customers/data_request', to: 'gdpr_webhooks#customers_data_request'
  post 'gdpr/customers/redact', to: 'gdpr_webhooks#customers_redact'
  post 'gdpr/shop/redact', to: 'gdpr_webhooks#shop_redact'


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

  resource :subscriptions, only: [:new, :create, :show, :edit, :update, :destroy]

  resource :shops, only: [:edit, :update], path: 'settings'

  resources :automations, only: [:index, :show, :edit, :update] do
    # get 'select_type', :on => :collection
  end

  # Routes for AWS Controller (to sign S3 uploads)
  get '/aws/sign', to: 'aws#sign'

  if Rails.env.development?
    get '/lob_debug' => 'postcard_render#debug'
  end

end
