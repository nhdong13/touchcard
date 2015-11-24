class RootController < AuthenticatedController
  def redis
    uri = URI.parse(ENV['REDISCLOUD_URL'])
    @redis ||= Redis.new(host: uri.host, port: uri.port, password: uri.password)
  end

  def bootstrap_index(index_key, app)
    return File.read("#{Rails.root}/private/index.html") unless Rails.env.production?
    index_key = redis.get("#{app}:index:current")
    if params[:index_key]
      index_key = "#{app}:index:#{params[:index_key]}"
    end
    logger.debug(index_key)
    redis.get(index_key)
  end

  def index
    redirect_to '/app'
  end

  def app
    text = bootstrap_index(params[:index_key], 'touchcard-app')
    render text: text
  end
end
