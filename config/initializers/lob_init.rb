Lob.configure do |config|
  if ENV['RAILS_ENV'] == "production"
    config.api_key = ENV['LOB_LIVE_API_KEY']
  elsif ENV['RAILS_ENV'] == "development"
    config.api_key = ENV['LOB_TEST_API_KEY']
  end
end

# Global Constants
WIDTH  = 1800
HEIGHT = 1200
