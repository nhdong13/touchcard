class RootController < AuthenticatedController
  def redis
    uri = URI.parse(ENV['REDISCLOUD_URL'])
    @redis ||= Redis.new(host: uri.host, port: uri.port, password: uri.password)
  end

  def bootstrap_index(index_key, app)
    return File.read("#{Rails.root}/private/index.html") unless Rails.env.production?
    index_key = redis.get("#{app}:index:current")
    if params[:index_key]
      index_key = "<your-project-name>:index:#{params[:index_key]}"
    end
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
