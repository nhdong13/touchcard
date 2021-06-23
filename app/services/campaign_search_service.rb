class CampaignSearchService
  def initialize current_shop, params
    @params = params
    @current_shop = current_shop
    @filters = get_filters
  end

  def index
    page = @params[:page] || 1
    campaigns = @current_shop.card_orders
    campaigns = campaigns.where("lower(card_orders.campaign_name) LIKE ?", "%#{@params[:query]}%") if @params[:query].present?
    campaigns = campaigns.where(campaign_type: filter_base_on_campaign_type) if filter_base_on_campaign_type != "any"
    campaigns = campaigns.where(campaign_status: filter_base_on_status) if !filter_base_on_status.empty?
    # CASE 
    #   WHEN campaign_status = 0 THEN updated_at BETWEEN :start_date AND :end_date
    #   ELSE created_at BETWEEN :start_date AND :end_date
    # END
    # 0 ==> draft
    campaigns = campaigns.where("CASE WHEN campaign_status = 0 THEN updated_at BETWEEN :start_date AND :end_date ELSE created_at BETWEEN :start_date AND :end_date END",{start_date: filter_base_on_date_created, end_date: filter_base_on_date_completed})
    campaigns = campaigns.page(page).order(created_at: :desc)
    total_pages = campaigns.total_pages
    return {
      campaigns: campaigns,
      total_pages: total_pages,
      campaign_types: campaign_types,
      statuses: statuses
    }
  end

  def get_filters
    if @current_shop.campaign_filter_option
      filters = @current_shop.campaign_filter_option
    else
      {}
    end
  end

  def filter_base_on_campaign_type
    @filters["type"] ? @filters["type"].downcase.split("-").join("_") : "any"
  end

  def filter_base_on_status
    if @filters["status"]
      return @filters["status"].map do |e|
        e.downcase
      end
    else
      return []
    end    
  end

  def filter_base_on_date_created
    return @current_shop.created_at if @filters["dateCreated"].empty?
    date = @filters["dateCreated"]["created_at"].to_time
  end

  def filter_base_on_date_completed
    return Time.now.utc if @filters["dateCreated"].empty?
    date = @filters["dateCreated"]["date_completed"].to_time
  end

  def campaign_types
    campaign_types = @current_shop.card_orders.pluck(:campaign_type).uniq
    campaign_types.map{ |c| c.capitalize.split("_").join("-") if c }
  end

  def statuses
    # TODO change it to status
    @current_shop.card_orders.pluck(:campaign_status).uniq.map { |s| s.capitalize unless s.nil? }
  end

end