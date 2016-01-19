class Api::V1::LineItemsController < Api::BaseController
  before_action :set_line_item, only: [:show]

  def show
    render json: @line_item
  end

  def index
    if params[:belongs]
      @line_items = LineItem.joins(:order)
        .where("orders.shop_id = ? AND orders.postcard_id IS NOT NULL", @current_shop.id)
        .order(created_at: :desc)
        .limit(100)
    else
      @line_items = LineItem.joins(:order)
        .where(orders: { shop_id: @current_shop.id })
        .order(created_at: :desc)
        .limit(100)
    end
    render json: @line_items
  end

  private

  def set_line_item
    @line_item = LineItem.find_by(id: params[:id])
    return render_not_found if @line_item.nil?
    render_authorization_error unless @line_item.order.shop_id == @current_shop.id
  end
end
