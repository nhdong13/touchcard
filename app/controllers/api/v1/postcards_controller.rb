class API::V1::PostcardsController < API::BaseController
  before_action :set_postcard, only: [:show, :update, :destoy]

  def index
    @postcards = @current_shop.postcards.where(sent: true).limit(20)
    render json: @postcards, each_serializer: PostcardSerializer
  end

  def show
    render json: @postcard, serializer: PostcardSerializer
  end

  private

  def set_postcard
    @postcard= Postcard.find_by(id: params[:id])
    return render_not_found unless @postcard
    render_authorization_error if @postcard.shop_id != @current_shop.id
  end
end
