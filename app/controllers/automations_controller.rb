class AutomationsController < BaseController
  def index
    @card_orders = @current_shop.card_orders
  end

  def new
    session[:current_step] = 0
    @types = CardOrder::TYPES
    @card = CardOrder.new
  end

  def create
  end

  def destroy
    @card = CardOrder.find(params[:id])
    @card.destroy
  end

  def next_step
    next_step = session[:current_step] + 1
    session[:current_step] = next_step
    session[:card_order_attrs] == permited_params
    render "step#{next_step}"
  end

  def permited_params
    params.require(:card_order).permit(:type)
  end
end
