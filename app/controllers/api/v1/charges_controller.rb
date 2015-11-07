class API::V1::ChargesController < BaseController

  validates :amount, customers: true

  def index
  end

  def show
    @charge = Charge.find_by(id: params[:id], shop_id: @current_shop.id)
    render json: @charge, serializer: ChargeSerializer
  end

  def new
  end

  def create
    @charge = @current_shop.charge.create(charge_params)
    @charge.new_shopify_charge
    render json: @charge, serializer: ChargeSerializer
  end

  def edit
  end

  def update
    # get the charge
    @charge = Charge.find(params[:charge_id], :shop => @current_shop)
    @charge.update_attributes(charge_params)
    render json: @charge, serializer: ChargeSerializer

  end

  def activate
    @charge = Chrage.find_by(:shopify_id => params[:charge_id])

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

    redirect_to @charge.last_page
  end

  private

  def charge_params
    params.require(:charge).permit(
      :id,
      :shopify_id,
      :amount,
      :recurring,
      :status,
      :shopify_redirect,
      :last_page)
  end

end
