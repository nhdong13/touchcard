class API::V1::ChargesController < API::BaseController
  before_action :set_charge, only: [:show, :update, :destroy]
  before_action :set_card_order, only: [:create]

  def show
    render json: @charge, serializer: ChargeSerializer
  end

  def create
    @charge = @current_shop.charges.create(create_params)
    return render_validation_errors(@charge) unless @charge.valid?
    @charge.create_shopify_charge
    render json: @charge, serializer: ChargeSerializer
  end

  def update
    success = @charge.update_attributes(charge_params)
    # TODO validation check for status cancelled
    return @charge.save unless render_validation_errors(@charge)
    @charge.cancel if @charge.status_changed? && @charge.status == "canceled"
    render json: @charge, serializer: ChargeSerializer
  end

  def activate
    @charge = Charge.find_by(id: params[:id], shopify_id: params[:charge_id])
    return render_not_found unless @charge
    return render_authorization_error unless @charge.token == params[:token]
    @charge.activate
    redirect_to @charge.last_page
  end

  private

  def set_charge
    @charge = Charge.find_by(id: params[:id])
    return render_not_found unless @charge
    render_authorization_error if @current_shop.id != @charge.shop_id
  end

  def set_card_order
    @card_order = CardOrder.find_by(id: params[:card_order_id])
    return render json: { errors: { card_order: "must be present"} } unless @card_order
    render_authorization_error unless @card_order.shop_id == @current_shop.id
  end

  def create_params
    params.require(:charge).permit(
      :card_order_id,
      :amount,
      :last_page).merge(
        recurring: @card_order.type == 'PostSaleOrder',
        status: 'new')
  end

  def update_params
    params.require(:charge).permit(:status)
  end
end
