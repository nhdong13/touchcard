class RootController < AuthenticatedController
  def redis
    uri = URI.parse(ENV['REDISCLOUD_URL'])
    @redis ||= Redis.new(host: uri.host, port: uri.port, password: uri.password)
  end

  def bootstrap_index(index_key, app)
    index_key ||= redis.get("#{app}:current")
    redis.get(index_key)
  end

  def app
    text = bootstrap_index(params[:index_key], 'touchcard-app')
    render text: text
  end
end
