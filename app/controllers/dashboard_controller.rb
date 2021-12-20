class DashboardController < BaseController
  def index
    CardOrder.unscoped do 
      @result = PostcardsService.new(@current_shop, postcards_search_params).all
      @postcards = @result[:postcards]
      @postcards_with_paging = @result[:postcards_with_paging]
      
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