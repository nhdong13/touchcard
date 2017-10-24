class AutomationsController < BaseController
  before_action :set_s3_direct_post, only: [:new, :edit, :update, :create]

  def index
    @card_orders = @current_shop.card_orders.where(archived: false)
  end

  def select_type
  end

  def new
    # @types = CardOrder::TYPES
    @card = @current_shop.card_orders.create
    # byebug

    # this is maybe not necessary --- we are using nested attributes
    # @card_side_back = @card.build_card_side_back(is_back: true)
    # @card_side_front = @card.build_card_side_front(is_back: false)
    # @filter = Filter.create(card_order: @card)
  end

  def edit
    puts params.to_yaml
    @card = CardOrder.find(params[:id])
  end

  def show
  end

  def update
    @card = CardOrder.find(params[:id])
    @card.update(permitted_params)
  end

  def create
    puts params.to_yaml
    CardOrder.create(type: 'PostSaleOrder', shop: @current_shop);
    redirect_to action: 'index'
  end

  def destroy
    @card = CardOrder.find(params[:id])
    @card.archive
    back_id = @card.card_side_back_id
    front_id = @card.card_side_front_id
    success = @card.destroy if @card.safe_to_destroy?
    delete_belonging_card_sides(back_id, front_id) if success
  end

  private

  def delete_belonging_card_sides(back_id, front_id)
    CardSide.find(back_id).destroy
    CardSide.find(front_id).destroy
  end

  private

  def set_s3_direct_post
    @s3_direct_post = S3_BUCKET
      .presigned_post(
        key: "uploads/#{SecureRandom.uuid}/${filename}",
        success_action_status: '201',
        acl: 'public-read')
  end

  def permitted_params
    params.permit(
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
