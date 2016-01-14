module ShopifyHelper
  def action_to_method(action)
    return :get if action == :show || action == :index
    return :post if action == :create
    return :delete if action == :destroy
    :post
  end

  def set_auth_header(params)
    digest = OpenSSL::Digest.new("sha256")
    api_secret = ENV["SHOPIFY_CLIENT_API_SECRET"]
    digested = OpenSSL::HMAC.digest(digest, api_secret, params.to_query)
    @request.headers["HTTP_X_SHOPIFY_HMAC_SHA256"] = Base64.encode64(digested).strip
  end

  def set_domain_header(shop)
    @request.headers["X-Shopify-Shop-Domain"] = shop.domain
  end

  def stub_shopify(entity, action=:show, options_in={})
    options = {
      example: :default,
      overrides: {}
    }.merge(options_in)
    response_text = File.read(
      "#{Rails.root}/spec/fixtures/shopify/#{entity}/#{action}/#{options[:example]}.json")
    response_obj = JSON.parse(response_text).with_indifferent_access
    base_uri = shop.shopify_api_path + "/"
    uri = "#{base_uri}#{options[:entity_uri] || entity}"
    uri = "#{uri}/#{response_obj[:id]}" if [:show, :update, :destroy].include?(action)
    method = action_to_method(action)
    response_obj.merge!(options[:overrides])
    stub_request(method, "#{uri}.json").to_return(body: response_obj.to_json)
    response_obj
  end
end
