class SubscriptionsController < BaseController
  before_action :set_subscription, only: [:show, :edit, :update, :destroy, :check_user_subscription]

  def new
    @subscription = Subscription.new
    @subscription.coupon = params[:coupon] if params[:coupon]
    @email = @current_shop.customer_email # OR @current_shop.email
  end

  def create
    quantity = create_params[:subscription][:quantity] # TODO: Handle missing quantity
    coupon = create_params[:subscription][:coupon]

    stripe_params = {shop: @current_shop, plan: Plan.last, quantity: quantity}
    stripe_params.merge!({coupon: coupon}) if !coupon.blank?

    @current_shop.create_stripe_customer(create_params[:stripeToken]) unless @current_shop.is_card_registered
    @subscription = Subscription.create(stripe_params)

    if @subscription.save
      @subscription.shop.top_up
      flash[:notice] = "Subscription successfully created"
      redirect_to root_path
    else
      flash[:error] = @subscription.errors.full_messages.join("\n")
      render :new
    end
  end

  def check_user_subscription
    respond_to do |format|
      result = @subscription.nil?
      format.html { redirect_to root_path }
      format.json { render json: { message: result }, status: :ok }
    end
  end


  def show
  end

  def edit
    @current_credit = @current_shop.current_subscription.quantity * (Plan.last.amount.to_f/100)
  end

  def update
    quantity = update_params[:quantity].to_i
    if quantity && @subscription.change_quantity(quantity)
      flash[:notice] = "Subscription successfully updated"
      redirect_to edit_shops_path
    else
      flash[:error] = @subscription.errors.full_messages.join("\n") || "Error Updating Subscription"
      render :edit
    end
  end

  def destroy
    if @subscription.change_quantity(0)
      flash[:notice] = "Subscription stopped"
      redirect_to edit_shops_path
    else
      flash[:error] = @subscription.errors.full_messages.join("\n") || "Error Updating Subscription"
      render :edit
    end
  end

  private

  def set_subscription
    @subscription = @current_shop.current_subscription
  end

  def create_params
    params.permit(
        :stripeToken,
        subscription: [:quantity, :coupon])
  end

  def update_params
    params.require(:subscription).permit(:quantity)
  end
end
