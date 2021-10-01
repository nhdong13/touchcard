class DashboardController < BaseController
  def index
    @current_page = params[:page].present? ? params[:page] : 1
    @postcards = @current_shop.postcards.where(paid: true)
      .or(@current_shop.postcards.where(canceled: true))
      .where(error: nil)
      .order(created_at: :desc)
      .page(@current_page)
      .per(20)
    respond_to do |format|
      format.html { render :index }
      format.json { render json: { 
        postcards: ActiveModelSerializers::SerializableResource.new(@postcards, {each_serializer: PostcardSerializer}).to_json
      }}
    end
  end

  def cancel_postcard
    @postcard = @current_shop.postcards.find(params[:id])
    @postcard.cancel
    render json: { postcard: PostcardSerializer.new(@postcard).to_json, message: "canceled", status: :ok }
  end
end
