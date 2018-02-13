class SubscriptionsController < BaseController
  def new
    @subscription = Subscription.new
  end

  def create
    quantity = permitted_params[:subscription][:quantity]
    @current_shop.create_stripe_customer(permitted_params[:stripeToken])
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

  def edit
  end

  def update
  end

  private

  def permitted_params
    params.permit(
        :stripeToken,
        subscription: [:quantity],

        )
  end

end
