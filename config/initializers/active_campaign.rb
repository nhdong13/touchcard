::ActiveCampaign.configure do |config|
  config.api_endpoint = ENV['AC_ENDPOINT'] # e.g. 'https://yourendpoint.api-us1.com/admin/api.php'
  config.api_key = ENV["AC_API_KEY"] # e.g. 'a4e60a1ba200595d5cc37ede5732545184165e'
end
