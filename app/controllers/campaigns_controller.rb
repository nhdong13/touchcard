class CampaignsController < BaseController
  def index
    @page = params[:page] || 1
    @campaigns = @current_shop.card_orders.page(@page)
    @total_pages = @campaigns.total_pages

    respond_to do |format|
      format.html {}
      format.json { render json: @campaigns.to_json(only: [:id, :type, :enabled]) }
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
        campaigns: @campaigns.to_json(only: [:id, :type, :enabled]),
        total_pages: @total_pages
      }}
    end
  end
end
