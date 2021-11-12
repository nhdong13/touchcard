class DashboardController < BaseController
  def index
    @current_page = params[:page].present? ? params[:page] : 1
    CardOrder.unscoped do 
      @postcards = @current_shop.postcards
        .or(@current_shop.postcards.where(canceled: true))
        .where(error: nil)
        .order(created_at: :desc)
        .page(@current_page)
        .per(20)
    end
    respond_to do |format|
      format.html { render :index }
      format.json { render json: { 
        postcards: ActiveModelSerializers::SerializableResource.new(@postcards, {each_serializer: PostcardSerializer}).to_json
      }}
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
end
