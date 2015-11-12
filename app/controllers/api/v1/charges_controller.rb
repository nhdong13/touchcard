class API::V1::ChargesController < API::BaseController
  before_action :set_charge, only: [:show, :update, :destroy]

  def index
    @charges = Charge.where(shop_id: @current_shop.id)
    render json: @charges, each_serializer: ChargeSerializer
  end

  def show
    render json: @charge, serializer: ChargeSerializer
  end

  def create
    @charge = Charge.new(charge_params)
    if @charge.save
      @charge.new_shopify_charge
      render json: @charge, serializer: ChargeSerializer
    else
      render_validation_errors(@charge)
    end
  end

  def update
    old_charge = @charge
    @charge.assign_attributes(charge_params)
    if @charge.save
      if @charge.status != old_charge.status and @charge.status == "canceled"
        @charge.cancel_plan
      end
      render json: @charge, serializer: ChargeSerializer
    else
      render_validation_errors(@charge)
    end

  end

  def activate
    @charge = Chrage.find_by(shopify_id: params[:charge_id])

    # Recurring or application?
    if @charge.recurring?
      old_charge = Charge.find_by(status: "active", recurring: true, shop_id: shop.id)

      #Find the charge on Shopify's end, and check that it is accepted
      shopify_charge = ShopifyAPI::RecurringApplicationCharge.find(params[:charge_id])
      if shopify_charge.status == "accepted"
        shopify_charge.activate
        @charge.update_attribute(:status, "active")
        old_charge.update_attribute(:status, "cancelled")

        # Update shop data and credits
        shop.update_attributes(charge_id: @charge.id, amount: @charge.amount, charge_date: Date.today )
        shop.top_up

      elsif shopify_charge.status == "active"
        puts "duplicate charge callback"
      end
    else
      # Bulk Charge
      shopify_charge = ShopifyAPI::ApplicationCharge.find(params[:charge_id])
      if shopify_charge.status == "accepted"
        shopify_charge.activate
        @charge.update_attribute(:status, "active")

        # Do the bulk send
        # NOTE: Should this be a card template, or a bulk_template? - Probably bulk
        @charge.bulk_template.update_attributes(status: "sending")
        @charge.bulk_template.bulk_send

      elsif shopify_charge.status == "active"
        puts "duplicate charge callback"
      end
    end
    redirect_to @charge.last_page
  end

  private

  def set_charge
    @charge = Charge.find_by(id: params[:id])
    return render_not_found unless @charge
    render_authorization_error if @current_shop.id != @charge.shop_id
  end

  def charge_params
    params.require(:charge).permit(
      :id,
      :shop_id,
      :card_order_id,
      :shopify_id,
      :amount,
      :recurring,
      :status,
      :shopify_redirect,
      :last_page)
  end

end
