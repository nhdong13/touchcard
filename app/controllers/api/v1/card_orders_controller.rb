class Api::V1::CardOrdersController < Api::BaseController
  before_action :set_card_order, only: [:show, :update, :destroy]

  def index
    @card_orders = @current_shop.card_orders
    render json: @card_orders, each_serializer: CardOrderSerializer
  end

  def show
    render json: @card_order, serializer: CardOrderSerializer
  end

  def create
    @card_order = type_name.create(create_params)
    return render_validation_errors(@card_order) unless @card_order.valid?
    render json: @card_order, serializer: CardOrderSerializer
  end

  def update
    success = @card_order.update_attributes(update_params)
    return render_validation_errors(@card_order) unless success
    render json: @card_order, serializer: CardOrderSerializer
  end

  def destroy
    @card_order.destroy
    render json: {}
  end

  private

  def set_card_order
    @card_order = type_name.find_by(id: params[:id], shop_id: @current_shop.id)
    render_not_found if @card_order.nil?
  end

  def update_params
    create_params
  end

  def type_name
    type = params[:card_order][:type]
    CardOrder::TYPES.include?(type) ? type.constantize : CardOrder
  end

  def create_params
    params.require(:card_order).permit(
      :type,
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
