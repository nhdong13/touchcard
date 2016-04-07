class RootController < AuthenticatedController
  # get the redis cloud connection
  def redis
    uri = URI.parse(ENV['REDISCLOUD_URL'])
    @redis ||= Redis.new(host: uri.host, port: uri.port, password: uri.password)
  end

  # WARNING: PELASE DON'T CHNAGE THIS WITHOUT GOOD REASON
  # this bootstraps ember through rails, so we can avoid CORS problems
  # if we are in development environemt load local ember assets, else
  # load from our redis in cloud
  def bootstrap_index(index_key, app)
    return File.read("#{Rails.root}/public/index.html") unless Rails.env.production?
    index_key = params[:index_key] || redis.get("#{app}:index:current")
    redis.get("#{app}:index:#{index_key}")
  end

  def index
    render layout: "embedded_app"
  end

  # dynamically setup shopify variables
  def app
    text = bootstrap_index(params[:index_key], 'touchcard-app')
    text.gsub!("https://{@shop_session.url}", @shop_session ? "https://#{@shop_session.url}" : "")
    shopify_js = "//cdn.shopify.com/s/assets/external/app.js?"
    text.gsub!(shopify_js, "#{shopify_js}#{Time.now.strftime('%Y%m%d%H')}")
    render text: text
  end
end
