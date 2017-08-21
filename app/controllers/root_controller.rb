class RootController < ShopifyApp::AuthenticatedController
  before_action :set_shop_and_scopes, only: [:oauth_entry_point, :app]
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

  def app
    if @shop.granted_scopes_suffice?(@scope)
      text = bootstrap_index(params[:index_key], 'touchcard-app')
      shopify_js = "//cdn.shopify.com/s/assets/external/app.js?"
      if text.present?
        shopify_key = ENV['SHOPIFY_CLIENT_API_KEY']
        text.gsub!("inject:shopify_client_api_key", shopify_key || "")
        text.gsub!("inject:shop_origin_url", @shop_session ? "https://#{@shop_session.url}" : "")
        text.gsub!(shopify_js, "#{shopify_js}#{Time.now.strftime('%Y%m%d%H')}")

        # Intercom User Identification
        text.gsub!("inject:user_email", @shop.email || "")
        text.gsub!("inject:user_name", @shop.name || "")
        text.gsub!("inject:user_created_at", @shop.created_at.to_i.to_s || "")
        text.gsub!("inject:user_shop_domain", @shop.domain || "")
        text.gsub!("inject:user_intercom_hmac", intercom_hmac(@shop.domain) || "")
      end
      render html: text.html_safe
    else
      redirect_to action: 'update_scope_prompt'
    end
  end

  # We're (only) sent here when a new oauth or oauth update happens
  # via shopify_app gem / sessions_concern.rb / root_url
  # We rely on that to give us a common place for updating oauth scopes
  def oauth_entry_point
    @shop.update_scopes(@scope)
    redirect_to action: 'app'
  end

  # Show a page that requests the user to update their oauth scope
  def update_scope_prompt
  end

  # Redirect the user to login, which will update their oauth scope
  def update_scope_redirect
    redirect_to "/login?shop=#{@shop_session.url}"
  end

  private

  def set_shop_and_scopes
    @shop ||= Shop.find(session[:shopify])
    @scope ||= ShopifyApp.configuration.scope
  end


  def intercom_hmac(user_id)
    OpenSSL::HMAC.hexdigest(
        'sha256', # hash function
        ENV['INTERCOM_SECRET'], # secret key (keep safe!)
        user_id # user's id
    )
  end

end
