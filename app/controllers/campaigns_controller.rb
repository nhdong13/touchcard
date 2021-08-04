class CampaignsController < BaseController
  def index
    @result = CampaignSearchService.new(@current_shop, params).index
    respond_to do |format|
      format.html {}
      format.json { render json: {
        campaigns: ActiveModelSerializers::SerializableResource.new(@result[:campaigns], {each_serializer: CardOrderSerializer}).to_json,
        total_pages: @result[:total_pages]
      }}
    end
  end

  def delete_campaigns
    return unless params[:campaign_ids]
    campaign_ids = params[:campaign_ids]
    campaign_ids.each do |campaign_id|
      campaign = CardOrder.find_by(id: campaign_id)
      PaymentService.refund_cards_when_cancelled @current_shop, campaign
      campaign.archive
    end
    @result = CampaignSearchService.new(@current_shop, params).index
    @total_pages = @result[:total_pages]
    respond_to do |format|
      format.html {}
      format.json { render json: {
        campaigns: ActiveModelSerializers::SerializableResource.new(@result[:campaigns], {each_serializer: CardOrderSerializer}).to_json,
        total_pages: @total_pages
      }}
    end
  end

  def export_csv
    card_oders = ActiveModelSerializers::SerializableResource.new(@current_shop.card_orders, {each_serializer: CardOrderSerializer}).to_json
    csv = ExportCsvService.new card_oders, CardOrder::CSV_ATTRIBUTES
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
