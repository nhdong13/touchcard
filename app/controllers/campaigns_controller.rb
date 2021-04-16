class CampaignsController < BaseController
  def index
    @result = CampaignSearchService.new(@current_shop, params).index
    respond_to do |format|
      format.html {}
      format.json { render json: {
        campaigns: @result[:campaigns].to_json(only: [:id, :name, :status, :budget, :type, :enabled]),
        total_pages: @result[:total_pages],
        statuses: @result[:statuses],
        types: @result[:types]
      }}
    end
  end

  def delete_campaigns
    campaign_ids = params[:campaign_ids]
    campaign_ids.each do |campaign_id|
      CardOrder.find_by(id: campaign_id).destroy
    end
    @campaigns = @current_shop.card_orders.page(1)
    @total_pages = @campaigns.total_pages

    respond_to do |format|
      format.html {}
      format.json { render json: {
        campaigns: @campaigns.to_json(only: [:id, :name, :status, :budget, :type, :enabled]),
        total_pages: @total_pages
      }}
    end
  end
end
