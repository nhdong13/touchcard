class AutomationsController < BaseController
  before_action :set_card_order, only: [:edit, :update, :show, :destroy]

  def index
    @card_orders = @current_shop.card_orders.active
  end

  def select_type
  end

  def new
    @automation = @current_shop.card_orders.new

    # this is maybe not necessary --- we are using nested attributes
    # @card_side_back = @card.build_card_side_back(is_back: true)
    # @card_side_front = @card.build_card_side_front(is_back: false)
    # @filter = Filter.create(card_order: @card)
  end


  def edit
  end

  def show
  end

  def update
    if @automation.update(automation_params)
      redirect_to automations_path, flash: { notice: "You've sucessfully update automation"}
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
    @automation.destroy_with_sides

    # TODO: Rescue exception
  # rescue
    # Catch error from transaction and do something
  end

  private

  def set_card_order
    @automation = @current_shop.card_orders.find(params[:id])
  end

  def automation_params
    params.require(:card_order).permit(
      :type,
      :enabled,
      :discount_exp,
      :discount_pct,
      filter_attributes: [:filter_data],
      card_side_front_attributes: [:image],
      card_side_back_attributes: [:image]
    )
  end
end
