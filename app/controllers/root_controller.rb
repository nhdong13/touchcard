class RootController < ShopifyApp::AuthenticatedController
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

  # dynamically setup shopify variables
  def app
    shop = Shop.find(session[:shopify])
    scope = ShopifyApp.configuration.scope

    shop.update_scopes(scope) if session[:update_scope]
    if shop.granted_scopes_match?(scope)
      session[:update_scope] = nil if session[:update_scope]
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
end
