class Api::V1::CardSidesController < Api::BaseController
  before_action :set_card_side, only: [:show, :update]

  def show
    render json: @card_side
  end

  def create
    @card_side = CardSide.create!(permited_params)
    return render_validation_errors(@card_side) unless @card_side.valid?
    render json: @card_side, serializer: CardSideSerializer
  end

  def update
    success = @card_side.update_attributes(update_params)
    return render json: @card_side if success
    render_validation_errors(@card_side)
  end

  private

  def update_params
    params.require(:card_side).permit(:image, :discount_x, :discount_y)
  end

  def permited_params
    params.require(:card_side).permit(
      :image,
      :discount_x,
      :discount_y,
      :is_back)
  end

  def set_card_side
    @card_side = CardSide.find_by(id: params[:id])
    return render_not_found if @card_side.nil?
    card_order_count = CardOrder.where("
      shop_id=? AND
      (card_side_back_id=? OR card_side_front_id=?)
    ", @current_shop.id, params[:id], params[:id]).count
    return render_authorization_error unless card_order_count > 0
    @card_side
  end
end
