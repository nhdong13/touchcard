# module for integrating with Active Campaign
module AcIntegrator
  class NewInstall
    attr_accessor :uri

    LIST_ID = ENV["AC_INSTALLED_SHOP_LIST_ID"]

    def initialize
      @uri = URI.parse("#{ENV['AC_ENDPOINT']}")
    end

    def add_email_to_list(email)
      params = {
        :"api_key" => ENV["AC_API_KEY"],
        :"api_action"=> "contact_add",
        :"api_output" => "json"
      }
      uri.query = URI.encode_www_form(params)
      request = Net::HTTP::Post.new(uri.request_uri)
      request.set_form_data({
        "email" => email,
        "p[#{LIST_ID}]" => LIST_ID
      })

      http.request(request)
    end

    private

    def http
      if @_http == nil
        @_http = Net::HTTP.new(uri.host, uri.port)
        @_http.use_ssl = true
      end
      @_http
    end

  end
end
