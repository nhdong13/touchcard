class AutomationsController < BaseController
  before_action :set_card_order, only: [:edit, :update, :show, :destroy]

  def index
    @card_orders = @current_shop.card_orders.active
  end

  def select_type
  end

  def new
    puts params.to_yaml
    @card_order = @current_shop.card_orders.new

    # this is maybe not necessary --- we are using nested attributes
    # @card_side_back = @card.build_card_side_back(is_back: true)
    # @card_side_front = @card.build_card_side_front(is_back: false)
    # @filter = Filter.create(card_order: @card)
  end


  def edit
    puts params.to_yaml
    # puts params.to_yaml
    # @card = CardOrder.find(params[:id])
  end

  def show
    puts params.to_yaml
  end

  def update
    puts params.to_yaml
    # @card = CardOrder.find(params[:id])
    # @card.update(permitted_params)
    # redirect_to action: 'index'

    if @card_order.update(card_order_params)
      redirect_to @card_order
    else
      render :edit
    end
  end


  def create
    puts params.to_yaml
    # CardOrder.create(type: 'PostSaleOrder', shop: @current_shop);
    # redirect_to action: 'index'

    # Type could come from as hidden field, param, etc
    create_params = {type: 'PostSaleOrder'}.merge(card_order_params)
    @card_order = @current_shop.card_orders.create(create_params)
    if @card_order.save
      redirect_to action: 'index', flash: { notice: "Automation successfully created" }
    else
      flash[:error] = @card_order.errors.full_messages.join("\n")
      render :new
    end
  end


  def destroy
    @card_order.archive
    @card_order.destroy_with_sides

    # TODO: Rescue exception
  # rescue
    # Catch error from transaction and do something
  end

  private

  def set_card_order
    @card_order = @current_shop.card_orders.find(params[:id])
  end

  def card_order_params
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

  # def permitted_params
  #   params.require(:card_order).permit(
  #     :type,
  #     :enabled,
  #     :discount_exp,
  #     :discount_pct,
  #     filter_attributes: [:filter_data],
  #     card_side_front_attributes: [:image],
  #     card_side_back_attributes: [:image]
  #   )
  # end

end
