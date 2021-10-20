class CampaignsController < BaseController
  def index
    @result = CampaignsService.new(@current_shop, campaigns_search_params).all
    respond_to do |format|
      format.html {}
      format.json { render json: {
        campaigns: ActiveModelSerializers::SerializableResource.new(@result[:campaigns], {each_serializer: CardOrderSerializer}).to_json,
        total_pages: @result[:total_pages]
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

  def delete_campaigns
    return unless params[:campaign_ids]
    campaign_ids = params[:campaign_ids]
    campaign_ids.each do |campaign_id|
      campaign = CardOrder.find_by(id: campaign_id)
      # PaymentService.refund_cards_when_cancelled @current_shop, campaign
      postcards = campaign.postcards.where(paid: false, sent: false, canceled: false)
      postcards.each do |postcard|
        postcard.canceled = true
        postcard.save!
      end

      campaign.archive
      campaign.safe_destroy! rescue nil
    end
    respond_to do |format|
      format.html {}
      format.json { render json: {message: "successful"}, status: 200}
    end
  end

  def duplicate_campaign
    DuplicateCampaignService.new(@current_shop, params[:campaign_id]).duplicate(params[:campaign_name])
    respond_to do |format|
      format.html {}
      format.json { render json: {message: "successful"}, status: 200}
    end
  end

  private
  def campaigns_search_params
    params.permit(:campaign_name, :page, :sort_by, :order)
  end
end
