class PostcardsService
  def initialize current_shop, params
    @current_shop = current_shop
    @params = params
  end

  def all
    current_page = @params[:page] || 1
    postcards = @current_shop.postcards.where(paid: true)
                .or(@current_shop.postcards.where(canceled: true))
                .where(error: nil)

    if @params[:sort_by].present?
      sort_order = @params[:order] || "asc"
      reverse_sort_order = sort_order == "asc" ? "desc" : "asc"
      case @params[:sort_by]
        when "status"
          postcards = postcards.order("sent #{sort_order} ,date_sent #{sort_order}, canceled #{reverse_sort_order}, send_date #{sort_order}")
        when "name"
          postcards = postcards.order("customer.first_name #{sort_order}, customer.last_name #{sort_order}")
        when "campaign"
          postcards = postcards.order("card_order.campaign_name #{sort_order}")
        when "location"
          postcards = postcards.order("default_addr.city #{sort_order}")
      end
    else
      postcards = postcards.order(created_at: :desc)
    end

    postcards = postcards.where(card_order_id: @params[:campaign_id]) if @params[:campaign_id].present?
    postcards_with_paging = postcards.includes(:card_order, :imported_customer, customer: :default_addr).page(current_page).per(20)

    {
      postcards: postcards,
      postcards_with_paging: postcards_with_paging  
    }
  end
end