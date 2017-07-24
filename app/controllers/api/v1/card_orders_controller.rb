class Api::V1::CardOrdersController < Api::BaseController
  before_action :set_card_order, only: [:show, :update, :destroy]

  def index
    @card_orders = if @current_shop.has_all_card_order_types?
      @current_shop.card_orders
    else
      CardOrder.create_cards(@current_shop)
    end
    render json: @card_orders, each_serializer: CardOrderSerializer
  end

  def show
    render json: @card_order, serializer: CardOrderSerializer
  end

  def create
    @card_order = CardOrder.create(create_params)
    return render_validation_errors(@card_order) unless @card_order.valid?
    render json: @card_order, serializer: CardOrderSerializer
  end

  def update
    success = @card_order.update_attributes(update_params)
    return render_validation_errors(@card_order) unless success
    render json: @card_order, serializer: CardOrderSerializer
  end

  def destroy
  end

  private

  def set_card_order
    @card_order = CardOrder.find_by(id: params[:id], shop_id: @current_shop.id)
    render_not_found if @card_order.nil?
  end

  def update_params
    create_params
  end

  def create_params
    params.require(:card_order).permit(
      :type_name,
      :discount_pct,
      :discount_exp,
      :enabled,
      :international,
      :send_delay,
      :arrive_by,
      :customers_before,
      :customers_after,
      :status).merge(shop_id: @current_shop.id)
  end
end
