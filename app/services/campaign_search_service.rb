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
    campaigns = campaigns.where(campaign_status: filter_base_on_status) if !filter_base_on_status.nil?
    campaigns = campaigns.where(created_at: filter_base_on_date_created..filter_base_on_date_completed)
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

  def get_filters
    if !@current_shop.campaign_filter_option.empty?
      filters = @current_shop.campaign_filter_option
      filters.reject!{|k, v| v.empty?} if filters
    else
      {}
    end
  end

  def filter_base_on_campaign_type
    if @filters["type"]
      return @filters["type"].downcase.split("-").join("_")
    else
      return "any"
    end
  end

  def filter_base_on_status
    if @filters["status"]
      return @filters["status"].map do |e|
        e.downcase
      end
    else
      return nil
    end    
  end

  def filter_base_on_date_created
    return @current_shop.created_at unless @filters["dateCreated"]
    date = @filters["dateCreated"]["created_at"].to_time
  end

  def filter_base_on_date_completed
    return Time.now.utc unless @filters["dateCreated"]
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