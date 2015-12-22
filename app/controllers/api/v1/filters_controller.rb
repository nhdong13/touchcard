class Api::V1::FiltersController < Api::BaseController
  before_action :set_filter, only: [:show, :update, :destroy]
  before_action :set_card_order, only: [:create]

  def create
    @filter = Filter.create(create_params)
    return render json: @filter if @filter.valid?
    render_validation_errors @filter
  end

  def show
    render json: @filter
  end

  def update
    success = @filter.update_attributes(update_params)
    return render json: @filter if success
    render_validation_errors @filter
  end

  def destroy
    @filter.destroy
    render json: {}
  end

  private

  def update_params
    # can't use permit because it's an object
    { filter_data: params.require(:filter)[:filter_data] }
  end

  def create_params
    update_params.merge(card_order: @card_order)
  end

  def set_filter
    @filter = Filter.find_by(id: params[:id])
    return render_not_found if @filter.nil?
    render_authorization_error unless @filter.card_order.shop_id == @current_shop.id
  end

  def set_card_order
    @card_order = CardOrder.find_by(id: params.require(:filter)[:card_order_id])
    return if @card_order.nil? || @card_order.shop_id == @current_shop.id
    render_authorization_error
  end
end
