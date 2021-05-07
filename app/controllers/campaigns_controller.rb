class CampaignsController < BaseController
  def index
    @result = CampaignSearchService.new(@current_shop, params).index
    respond_to do |format|
      format.html {}
      format.json { render json: {
        campaigns: ActiveModelSerializers::SerializableResource.new(@result[:campaigns], {each_serializer: CardOrderSerializer}).to_json,
        total_pages: @result[:total_pages],
        statuses: @result[:statuses],
        campaign_types: @result[:campaign_types]
      }}
    end
  end

  def delete_campaigns
    return unless params[:campaign_ids]
    campaign_ids = params[:campaign_ids]
    campaign_ids.each do |campaign_id|
      CardOrder.find_by(id: campaign_id).archive
    end
    @campaigns = @current_shop.card_orders.page(1)
    @total_pages = @campaigns.total_pages

    respond_to do |format|
      format.html {}
      format.json { render json: {
        campaigns: ActiveModelSerializers::SerializableResource.new(@campaigns, {each_serializer: CardOrderSerializer}).to_json,
        total_pages: @total_pages
      }}
    end
  end

  def export_csv
    csv = ExportCsvService.new CardOrder.all, CardOrder::CSV_ATTRIBUTES
    respond_to do |format|
      format.json { render json: {
        csv_data: csv.perform.to_json,
        filename: "#{@current_shop.domain}_campaigns.csv" }
      }
    end
  end

  def duplicate_campaign
    DuplicateCampaignService.new(@current_shop, params).duplicate
    @result = CampaignSearchService.new(@current_shop, params).index
    respond_to do |format|
      format.html {}
      format.json { render json: {
        campaigns: ActiveModelSerializers::SerializableResource.new(@result[:campaigns], {each_serializer: CardOrderSerializer}).to_json,
        total_pages: @result[:total_pages],
        statuses: @result[:statuses],
        campaign_types: @result[:campaign_types]
      }}
    end
  end
end
