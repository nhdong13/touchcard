class AutomationsController < BaseController

  def index
    @card_orders = @current_shop.card_orders.where(archived: false)
  end

  def select_type
  end

  def new
    # @types = CardOrder::TYPES
    @card = @current_shop.card_orders.create
    # byebug

    # this is maybe not necessary --- we are using nested attributes
    # @card_side_back = @card.build_card_side_back(is_back: true)
    # @card_side_front = @card.build_card_side_front(is_back: false)
    # @filter = Filter.create(card_order: @card)
  end

  def edit
    puts params.to_yaml
    @card = CardOrder.find(params[:id])
  end

  def show
  end

  def update
    @card = CardOrder.find(params[:id])
    @card.update(permitted_params)
    redirect_to action: 'index'
  end

  def create
    puts params.to_yaml
    CardOrder.create(type: 'PostSaleOrder', shop: @current_shop);
    redirect_to action: 'index'
  end

  def destroy
    @card = CardOrder.find(params[:id])
    @card.archive
    if @card.safe_to_destroy?
      # The CardOrder / CardSide relation is backwards for easy destroy propagation, so this is a workaround
      @card.transaction do
        @card.destroy
        CardSide.find(@card.card_side_back_id).destroy
        CardSide.find(@card.card_side_front_id).destroy
      end
    end
  end

  private
  def permitted_params
    params.require(:card_order).permit(
      :type,
      :enabled,
      :discount_exp,
      :discount_pct,
      filter_attributes: [:filter_data],
      card_side_front_attributes: [:image],
      card_side_back_attributes: [:image]
    )
  end
end
