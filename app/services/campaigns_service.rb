class CampaignsService
  def initialize current_shop, params
    @params = params
    @current_shop = current_shop
    # @filters = get_filters
  end

  # Campaigns query
  def all
    page = @params[:page] || 1
    campaigns = @current_shop.card_orders
    campaigns = campaigns.where("lower(card_orders.campaign_name) LIKE ?", "%#{@params[:campaign_name]}%") if @params[:campaign_name].present?
    # campaigns = campaigns.where(campaign_type: filter_base_on_campaign_type) if filter_base_on_campaign_type != "any"
    # campaigns = campaigns.where(campaign_status: filter_base_on_status) if !filter_base_on_status.empty?
    # # CASE 
    # #   WHEN campaign_status = 0 THEN updated_at BETWEEN :start_date AND :end_date
    # #   ELSE created_at BETWEEN :start_date AND :end_date
    # # END
    # # 0 ==> draft
    # campaigns = campaigns.where("CASE WHEN campaign_status = 0 THEN updated_at BETWEEN :start_date AND :end_date ELSE created_at BETWEEN :start_date AND :end_date END",{start_date: filter_base_on_date_created, end_date: filter_base_on_date_completed})
    if @params[:sort_by].present?
      sort_order = @params[:order] || "asc"
      campaigns = campaigns.order("#{@params[:sort_by]} #{sort_order}")
    else
      campaigns = campaigns.order(created_at: :desc)
    end
    campaigns = campaigns.page(page)
    total_pages = campaigns.total_pages
    return {
      campaigns: campaigns,
      total_pages: total_pages
    }
  end

  # Duplicate campaign
  
=begin
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
        e.downcase.split(" ").join("_")
      end
    else
      return []
    end    
  end

  def filter_base_on_date_created
    return @current_shop.created_at unless @filters["dateCreated"].present? && @filters["dateCreated"]["created_at"].present?
    date = @filters["dateCreated"]["created_at"].to_time
  end

  def filter_base_on_date_completed
    return Time.now.utc unless @filters["dateCreated"].present? && @filters["dateCreated"]["date_completed"].present?
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
=end
end