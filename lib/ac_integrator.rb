# module for integrating with Active Campaign
module AcIntegrator
  class NewInstall
    attr_accessor :uri

    LIST_ID = ENV["AC_INSTALLED_SHOP_LIST_ID"]

    def initialize
      @uri = URI.parse("#{ENV['AC_ENDPOINT']}")
    end

    def add_contact(email, domain=nil, first_name=nil, last_name=nil, tags=nil)
      params = {
        :"api_key" => ENV["AC_API_KEY"],
        :"api_action"=> "contact_add",
        :"api_output" => "json"
      }

      uri.query = URI.encode_www_form(params)
      request = Net::HTTP::Post.new(uri.request_uri)

      form_data = {
          "email" => email,
          "p[#{LIST_ID}]" => LIST_ID
      }
      form_data["field[%STORE_URL%,0]"] = domain if domain
      form_data["first_name"] = first_name if first_name
      form_data["last_name"] = last_name if last_name
      form_data["tags"] = tags.join(",") if tags


      request.set_form_data(form_data)
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
