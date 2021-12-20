class DashboardController < BaseController
  def index
    CardOrder.unscoped do 
      @result = PostcardsService.new(@current_shop, postcards_search_params).all
      @postcards = @result[:postcards]
      @postcards_with_paging = @result[:postcards_with_paging]

      campaigns_have_postcards = @current_shop.card_orders.have_postcards.order(:campaign_name)
      @campaigns_for_dropdown = campaigns_have_postcards.active.pluck(:campaign_name, :id).uniq + 
                                campaigns_have_postcards.unactive.pluck(:campaign_name, :id).uniq.each { |array| 
                                  array[0] = "(Deleted) #{array[0]}" 
                                }

      respond_to do |format|
        format.html { render :index }
        format.json { render json: { 
          postcards: ActiveModelSerializers::SerializableResource.new(@postcards_with_paging, {each_serializer: PostcardSerializer}).to_json
        }}
      end
    end
  end

  def cancel_postcard
    @postcard = @current_shop.postcards.find(params[:id])
    if @postcard.canceled || @postcard.sent
      render json: { postcard_sent: @postcard.sent , message: "cannot cancel", status: :ok}
    else
      @postcard.cancel
      render json: { message: "canceled", status: :ok}
    end
  end

  private
  def postcards_search_params
    params.permit(:campaign_id, :sort_by, :order, :page)
  end
end