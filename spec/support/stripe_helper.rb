module StripeHelper
  BASE_URI = "https://api.stripe.com/v1/"

  def action_to_method(action)
    return :get if action == :show || action == :index
    return :post if action == :create
    return :delete if action == :destroy
    :post
  end

  def stub_stripe(entity, action=:show, options_in={})
    options = {
      example: :default,
      overrides: {}
    }.merge(options_in)
    response_text = File.read(
      "#{Rails.root}/spec/fixtures/stripe/#{entity}/#{action}/#{options[:example]}.json")
    response_obj = JSON.parse(response_text).with_indifferent_access
    uri = "#{BASE_URI}#{options[:entity_uri] || entity}"
    uri = "#{uri}/#{response_obj[:id]}" if [:show, :update, :destroy].include?(action)
    method = action_to_method(action)
    response_obj.merge!(options[:overrides])
    stub_request(method, uri).to_return(body: response_obj.to_json)
    response_obj
  end
end
