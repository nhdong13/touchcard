class SubscriptionsController < BaseController
  before_action :set_subscription, only: [:show, :edit, :update, :destroy]

  def new
    @subscription = Subscription.new
  end

  def create
    quantity = create_params[:subscription][:quantity]
    @current_shop.create_stripe_customer(create_params[:stripeToken])
    @subscription = Subscription.create(shop: @current_shop, plan: Plan.first, quantity: quantity)

    respond_to do |format|
      if @subscription.save
        @subscription.shop.top_up
        flash[:notice] = "Subscription successfully created"
        format.html { render :create}
        format.json { render json: @subscription }
      else
        flash[:error] = @subscription.errors.full_messages.join("\n")
        format.html { render :new }
        format.json { render json: subscription.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
  end

  def edit
  end

  def update
    quantity = update_params[:quantity].to_i
    if quantity && @subscription.change_quantity(quantity)
      flash[:notice] = "Subscription successfully updated"
      redirect_to edit_shop_path
    else
      flash[:error] = @subscription.errors.full_messages.join("\n") || "Error Updating Subscription"
      render :edit
    end
  end

  def destroy
    if @subscription.change_quantity(0)
      flash[:notice] = "Subscription stopped"
      redirect_to edit_shop_path
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
        subscription: [:quantity])
  end

  def update_params
    params.require(:subscription).permit(:quantity)
  end

end
