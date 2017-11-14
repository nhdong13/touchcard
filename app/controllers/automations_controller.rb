class AutomationsController < BaseController
  before_action :set_automation, only: [:edit, :update, :show, :destroy]

  def index
    @card_orders = @current_shop.card_orders.active
  end

  def select_type
  end

  def new
    @automation = @current_shop.card_orders.new
    @automation.build_card_side_back(is_back: true)
    @automation.build_card_side_front(is_back: false)
  end


  def edit
  end

  def show
  end

  def update
    if @automation.update(automation_params)
      redirect_to automations_path, flash: { notice: "Automation successfully updated"}
    else
      render :edit
    end
  end


  def create
    @automation = @current_shop.post_sale_orders.create(automation_params)

    if @automation.save
      redirect_to action: 'index', flash: { notice: "Automation successfully created" }
    else
      flash[:error] = @automation.errors.full_messages.join("\n")
      render :new
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
