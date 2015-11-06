class API::V1::ChargesController < BaseApiController

  def index
  end

  def show
    @charge = Charge.find_by(id: params[:id], shop_id: @current_shop.id)
    render json: @charge, serializer: ChargeSerializer
  end

  def new
  end

  def create
  end

  def edit
    @charge = Charge.find_by(id: params[:id], shop_id: @current_shop.id)
    render json: @charge, serializer: ChargeSerializer
  end

  def update
    # get the charge
    @charge = Charge.find(params[:charge_id])
    shop = @charge.shop
    shop.new_sess

    # Recurring or application?
    if @charge.recurring?
      old_charge = Charge.find_by(:status => "canceling", :shop_id => shop.id)

      #Find the charge on Shopify's end, and check that it is accepted
      shopify_charge = ShopifyAPI::RecurringApplicationCharge.find(params[:charge_id])
      if shopify_charge.status == "accepted"
        shopify_charge.activate
        @charge.update_attribute(:status, "active")
        old_charge.update_attribute(:status, "cancelled")

        # Update shop data and credits
        shop.update_attributes(:charge_id => @charge.id, :amount => (@charge.amount/0.99).to_i , :charge_date => Date.today )
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
      elsif shopify_charge.status == "active"
        puts "duplicate charge callback"
      end
    end

    render json: @charge, serializer: ChargeSerializer

  end

end
