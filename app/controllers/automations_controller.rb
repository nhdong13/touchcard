class AutomationsController < BaseController
  before_action :set_automation, only: [:edit, :update, :show, :destroy]
  before_action :set_aws_sign_endpoint, only: [:new, :edit]

  def index
    # Create default automation if there isn't one already
    if @current_shop.card_orders.count == 0
      card_order = @current_shop.card_orders.new
      card_order.build_card_side_back(is_back: true)
      card_order.build_card_side_front(is_back: false)
      card_order.save
    end

    # This flash works, but it's sort of annoying
    # if @current_shop.current_subscription && @current_shop.current_subscription.quantity.to_i > 0 && CardOrder.num_enabled == 0
    #   flash[:notice] = "You are subscribed but not sending. Enable an automation to start sending."
    # end

    @card_orders = @current_shop.card_orders.active
  end

  def show
  end

  # def select_type
  # end

  # TODO: Re-enable automation creation
  #
  # def new
  #   @automation = @current_shop.card_orders.new
  #   @automation.build_card_side_back(is_back: true)
  #   @automation.build_card_side_front(is_back: false)
  # end


  def edit
  end

  # POST /automations
  # POST /automations.json
  def create
    @automation = @current_shop.post_sale_orders.create(automation_params)
    respond_to do |format|
      if @automation.save
        flash[:notice] = "Automation successfully created"
        format.html { redirect_to action: 'index'}
        format.json { render json: @automation }
      else
        flash[:error] = @automation.errors.full_messages.join("\n")
        format.html { render :new }
        format.json { render json: @automation.errors, status: :unprocessable_entity }
      end
    end

  end

  # PATCH/PUT /automations/1
  # PATCH/PUT /automations/1.json
  def update
    respond_to do |format|
      if @automation.update(automation_params)
        flash[:notice] = "Automation successfully updated"
        format.html { redirect_to automations_path }
        format.json { render json: { message: "updated"}, status: :ok }
      else
        flash[:error] = @automation.errors.full_messages.join("\n")
        format.html { render :edit }
        format.json { render json: @automation.errors, status: :unprocessable_entity }
      end
    end
  end

  # TODO: Re-enable automation destruction
  #
  # def destroy
  #   @automation.archive
  #   @automation.safe_destroy!
  #   # TODO: Rescue exception
  # # rescue
  #   # Catch error from transaction and do something
  # end

  private

  def set_automation
    @automation = @current_shop.card_orders.find(params[:id])
  end

  def set_aws_sign_endpoint
    @aws_sign_endpoint = root_url + aws_sign_path
  end

  def automation_params
    params.require(:card_order).permit(
      :type,
      :enabled,
      :discount_exp,
      :discount_pct,
      :international,
      :send_delay,
      filters_attributes: [[:id, :_destroy, filter_data: [:minimum, :maximum]]],
      front_json: [:version, :background_url, :discount_x, :discount_y],
      back_json: [:version, :background_url, :discount_x, :discount_y],
    )
  end
end
