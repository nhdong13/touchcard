class Api::V1::PostcardsController < Api::BaseController
  before_action :set_postcard, only: [:show, :update, :destoy]

  def index
    @postcards = @current_shop.postcards.where(paid: true).order(updated_at: :desc).limit(20)
    render json: @postcards, each_serializer: PostcardSerializer
  end

  def show
    render json: @postcard, serializer: PostcardSerializer
  end

  def update
    shop = @postcard.shop
    success = @postcard.update_attributes(postcard_params)
    shop.return_credit if @postcard.canceled_changed? && @postcard.canceled

    return render_validation_errors(@postcard) unless success
    render json: @postcard, serializer: PostcardSerializer
  end

  private

  def set_postcard
    @postcard= Postcard.find_by(id: params[:id])
    return render_not_found unless @postcard
    render_authorization_error if @postcard.shop_id != @current_shop.id
  end

  def postcard_params
    params.require(:postcard).permit(:canceled)
  end
end
