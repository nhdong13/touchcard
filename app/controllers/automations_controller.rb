class AutomationsController < BaseController
  before_action :set_automation, only: [:edit, :update, :show, :destroy]

  def index
    @card_orders = @current_shop.card_orders.active
  end

  def show
  end

  # def select_type
  # end

  def new
    @automation = @current_shop.card_orders.new
    @automation.build_card_side_back(is_back: true)
    @automation.build_card_side_front(is_back: false)
  end


  def edit
  end

  # POST /automations
  # POST /automations.json

  # AND NOW DO THIS: TODO: And now copy over html / json responses
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
        format.json { render json: {}, status: :ok }
      else
        flash[:error] = @automation.errors.full_messages.join("\n")
        format.html { render :edit }
        format.json { render json: @automation.errors, status: :unprocessable_entity }
      end
    end
  end





  def destroy
    @automation.archive
    @automation.safe_destroy!
    # TODO: Rescue exception
  # rescue
    # Catch error from transaction and do something
  end

  private

  def set_automation
    @automation = @current_shop.card_orders.find(params[:id])
  end

  def automation_params
    params.require(:card_order).permit(
      :type,
      :enabled,
      :discount_exp,
      :discount_pct,
      :international,
      :send_delay,
      filter_attributes: [:filter_data],
      card_side_front_attributes: [:image],
      card_side_back_attributes: [:image]
    )
  end
end
