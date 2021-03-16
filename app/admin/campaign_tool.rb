ActiveAdmin.register_page "Campaign Tool" do
  menu priority: 16
  LOB_API_KEY = 'test_aa438bb1735c587df0bb27c8ecf0c82e8a6'
  # BASE_CAMPAIGN_TOOL_URL = 'https://campaign-tool-dev.herokuapp.com'
  BASE_CAMPAIGN_TOOL_URL = 'http://localhost:3001/'
  TEST_ADDRESS_TO = "adr_8769d8839f5c16c4"

  content do
    @@lob ||= Lob::Client.new(api_key: LOB_API_KEY)
    @postcard = @@lob.postcards.find("psc_12f4ba9c1a06ebc0")

    render "upload_csv"
  end

  page_action :upload_csv, method: :post do
    link_to 'Upload CSV', :action => 'upload_csv'
  end

  page_action :send_post_cards_to_lob, method: :post do
    post_card_id = params[:post_card_id]
    url = "#{BASE_CAMPAIGN_TOOL_URL}/api/v1/post_cards/send_post_cards_to_lob"
    resp = Faraday.post(url, {post_card_id: post_card_id}, {'Accept' => 'application/json'})
    if resp.status == 200
      respond_to do |format|
        format.json { render json: { message: "Successfully!", success: true } }
      end && return
    end
  end

  page_action :create_test_post_card, method: :post do
    return render json: {
      success: false,
      message: "Missing campaign id",
    } unless params[:test_campaign_id].present?
    @@lob ||= Lob::Client.new(api_key: LOB_API_KEY)
    begin
      @post_card_info = PostCardInfo.create(
        campaign_id: params[:test_campaign_id],
        front_design: params[:front_design_file],
        back_design: params[:back_design_file]
      )
      front_url = @post_card_info.front_design.url
      back_url = @post_card_info.back_design.url
      sent_card = @@lob.postcards.create(
        {
          description: params[:test_campaign_id],
          metadata: {
            campaign_id: params[:test_campaign_id],
            front_url: front_url,
            back_url: back_url
          },
          to: TEST_ADDRESS_TO,
          from: from_address(params[:from]),
          front: front_url,
          back: back_url,
        })
      @postcard = @@lob.postcards.find(sent_card["id"])
      @post_card_url =  @postcard["url"]
      respond_to do |format|
        format.json {
          render json: {
            redirect_path: admin_campaign_tool_preview_post_card_path(postcard_id: sent_card["id"]),
            success: true
          }
        }
      end && return
    rescue Lob::InvalidRequestError => e
      flash[:error] = e
      respond_to do |format|
        format.json { render json: { message: e.message, success: false } }
      end && return
    end
  end



  page_action :preview_post_card, method: :get do
    @@lob ||= Lob::Client.new(api_key: LOB_API_KEY)
    @postcard = @@lob.postcards.find(params[:postcard_id])
    @post_card_url =  @postcard["url"]
  end

  page_action :import_csv, :method => :post do
    return render json: {
      success: false,
      message: "Missing campaign id",
    } unless params[:campaign_id].present?
    csv_path = csv_path = params[:csv_file].path
    converter = lambda { |header| header.downcase }
    data = CSV.read(csv_path, headers: true, encoding: 'ISO-8859-1', col_sep: ",", header_converters: converter)
    arrayVal = []
    data.each do |row|
      next if row.fields.compact.empty? # Row without data
      addr1 = row['address 1'] || row['address']
      country = row['country']
      raw_zip = row['zip']
      zip = (row['country']&.downcase == "us" && !!/^\d+$/.match(raw_zip)) ? raw_zip.rjust(5, '0') : raw_zip
      arrayVal.push({
        email: row['email'],
        name: row['name'],
        addr1:addr1,
        addr2:row['address 2'],
        city: row['city'],
        state: row['state'],
        raw_zip: raw_zip,
        country: country,
        zip: zip
      })
    end
    url = "#{BASE_CAMPAIGN_TOOL_URL}/api/v1/post_cards/add_post_cards"
    resp = Faraday.post(
      url,
      {campaign_id: params[:campaign_id], data: arrayVal.to_json},
      {'Accept' => 'application/json', 'Authorization': "Bearer #{@auth_token}"}
    )
    body = JSON.parse resp.body
    @message = body["message"] && body["message"]
    respond_to do |format|
      format.json { render json: { message: @message, success: resp.status == 200 } }
    end
  end

  controller do
    before_action :get_auth_token, only: [:import_csv, :send_post_cards_to_lob]

    def get_auth_token
      url = "#{BASE_CAMPAIGN_TOOL_URL}/authenticate"
      user = {email: "nusnick@yopmail.com", password: "12345678"}
      resp = Faraday.post(url, user, {'Accept' => 'application/json'})
      @auth_token = nil
      if resp.status == 200
        body = JSON.parse resp.body
        @auth_token = body["auth_token"]
      end
      @auth_token
    end

    def from_address address_attrs
      {
        name: address_attrs[:name],
        address_line1: address_attrs[:address_line1],
        address_line2: address_attrs[:address_line1],
        address_city: address_attrs[:city],
        address_state: address_attrs[:state],
        address_zip: address_attrs[:zip]
      }
    end
  end
end