class CampaignSearchService
  def initialize current_shop, params
    @params = params
    @current_shop = current_shop
  end

  def index
    page = @params[:page] || 1
    campaigns = @current_shop.card_orders
    campaigns = campaigns.where("lower(card_orders.name) LIKE ?", "%#{@params[:query]}%") if @params[:query].present?
    campaigns = campaigns.where(campaign_type: filter_base_on_campaign_type) if filter_base_on_campaign_type.present?
    campaigns = campaigns.where(campaign_status: filter_base_on_status) if filter_base_on_status
    campaigns = campaigns.where(created_at: filter_base_on_date_created) if filter_base_on_date_created
    # campaigns = campaigns.where(status: filter_base_on_date_completed) if filter_base_on_date_completed
    campaigns = campaigns.page(page).order(created_at: :desc)
    total_pages = campaigns.total_pages

    return {
      campaigns: campaigns,
      total_pages: total_pages,
      campaign_types: campaign_types,
      statuses: statuses
    }
  end

  def filters
    if @params[:filters]
      filters = JSON.parse(@params[:filters])
      filters.reject!{|k, v| v.empty?} if filters
    else
      {}
    end
  end

  def filter_base_on_campaign_type
    filters["type"] ? filters["type"].downcase.split("-").join("_") : ""
  end

  def filter_base_on_status
    filters["status"].downcase if filters["status"]
  end

  def filter_base_on_date_created
    return nil unless filters["created_at"]
    date = filters["created_at"].to_time
    date.beginning_of_day..date.end_of_day
  end

  def filter_base_on_date_completed
    return nil unless filters["date_completed"]
    date = filters["date_completed"].to_time
    date.beginning_of_day..date.end_of_day
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