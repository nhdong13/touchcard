class AutomationsController < BaseController
  def index
    @card_orders = @current_shop.card_orders
  end


  def select_type
  end

  def new
    @types = CardOrder::TYPES
    @card = @current_shop.card_orders.create
    # this is maybe not necessary --- we are using nested attributes
    # @card_side_back = @card.build_card_side_back(is_back: true)
    # @card_side_front = @card.build_card_side_front(is_back: false)
    # @filter = Filter.create(card_order: @card)
  end

  def show
  end
  
  def create
    debugger
  end

  def destroy
    @card = CardOrder.find(params[:id])
    @card.destroy
  end

  def permited_params
    params.require(:card_order).permit(
      :type,
      :discount_exp,
      :discount_pct,
      filter_attributes: [:filter_data],
      card_side_front_attributes: [:image],
      card_side_back_attributes: [:image]
    )
  end
end
