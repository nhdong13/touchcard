class RootController < ShopifyApp::AuthenticatedController
  before_action :set_shop_and_scopes, only: [:index, :app]
  # get the redis cloud connection
  def redis
    uri = URI.parse(ENV['REDISCLOUD_URL'])
    @redis ||= Redis.new(host: uri.host, port: uri.port, password: uri.password)
  end

  # WARNING: PLEASE DON'T CHANGE THIS WITHOUT GOOD REASON
  # this bootstraps ember through rails, so we can avoid CORS problems
  # if we are in development environment load local ember assets, else
  # load from our redis in cloud
  def bootstrap_index(index_key, app)
    return File.read("#{Rails.root}/public/client/index.html") unless Rails.env.production?
    index_key = params[:index_key] || redis.get("#{app}:index:current")
    redis.get("#{app}:index:#{index_key}")
  end

  def index
    # We're sent here when a new auth or auth update happens.
    if session[:update_scope]
      @shop.update_scopes(@scope)
      session[:update_scope] = nil
    end
    redirect_to action: 'app'
  end


  def app
    if @shop.granted_scopes_suffice?(@scope)
      text = bootstrap_index(params[:index_key], 'touchcard-app')
      shopify_js = "//cdn.shopify.com/s/assets/external/app.js?"
      if text.present?
        shopify_key = ENV['SHOPIFY_CLIENT_API_KEY']
        text.gsub!("inject:shopify_client_api_key", shopify_key ? shopify_key : "")
        text.gsub!("inject:shop_origin_url", @shop_session ? "https://#{@shop_session.url}" : "")
        text.gsub!(shopify_js, "#{shopify_js}#{Time.now.strftime('%Y%m%d%H')}")
      end
      render text: text
    else
      redirect_to action: 'update_scope_prompt'
    end
  end

  def update_scope_prompt
    # Show a page that requests the user to update their oauth scope
  end


  def update_scope_redirect
    # Redirect the user to login, which will update their oauth scope
    session[:update_scope] = true
    redirect_to "/login?shop=#{@shop_session.url}"
  end

  private


  def set_shop_and_scopes
    @shop ||= Shop.find(session[:shopify])
    @scope ||= ShopifyApp.configuration.scope
  end

end
