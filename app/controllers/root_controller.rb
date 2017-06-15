class RootController < ShopifyApp::AuthenticatedController
  before_action :set_shop_and_scopes, only: [:scopecheck, :app]
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
    render layout: "embedded_app"
  end

  def scopecheck
    if session[:update_scope]
      update_scopes_and_redirect_to_app_url(@shop, @scope)
    else
      redirect_to action: 'app'
    end
  end

  # dynamically setup shopify variables
  def app
    if @shop.granted_scopes_suffice?(@scope)
      boot_app
    else
      redirect_to action: 'edit_scope'
    end
  end

  def edit_scope
  end

  def update_scope
    session[:update_scope] = true
    redirect_to "/login?shop=#{@shop_session.url}"
  end

  private

  def update_scopes_and_redirect_to_app_url(shop, scope)
    shop.update_scopes(scope)
    session[:update_scope] = nil
    redirect_to action: 'app'
  end

  def boot_app
    text = bootstrap_index(params[:index_key], 'touchcard-app')
    shopify_js = "//cdn.shopify.com/s/assets/external/app.js?"
    if text.present?
      shopify_key = ENV['SHOPIFY_CLIENT_API_KEY']
      text.gsub!("inject:shopify_client_api_key", shopify_key ? shopify_key : "")
      text.gsub!("inject:shop_origin_url", @shop_session ? "https://#{@shop_session.url}" : "")
      text.gsub!(shopify_js, "#{shopify_js}#{Time.now.strftime('%Y%m%d%H')}")
    end
    render text: text
  end

  def set_shop_and_scopes
    @shop = Shop.find(session[:shopify])
    @scope = ShopifyApp.configuration.scope
  end

end
