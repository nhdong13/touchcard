class API::V1::CardOrdersController < API::BaseController
  before_action :set_card_order, only: [:show, :update, :destroy]

  def index
    @card_orders = CardOrder.where(shop_id: @current_shop.id)
    render @card_orders, each_serializer: CardOrderSerializer
  end

  def show
    render json: @card_order, serializer: CardOrderSerializer
  end

  def create
    @card_order = CardOrder.new(create_params)
    if @card_order.save
      render json: @card_order, serializer: CardOrderSerializer
    else
      # return 422 error
      puts @card_order.errors.full_messages
      puts @card_order.shop_id
      render json: { errors: @card_order.errors }, status: 422
    end

  end

  def update
    @card_order.assign_attributes(discount_params)

    if create_params.has_key?(:image_back)
      @card_order.image_back = AwsUtils.upload_to_s3(create_params[:image_back].original_filename, create_params[:image_back].path)
    end

    if create_params.has_key?(:image_front)
      @card_order.image_front = AwsUtils.upload_to_s3(create_params[:image_front].original_filename, create_params[:image_front].path)
    end

    if @card_order.save
      if create_params.has_key?(:image_back) or create_params.has_key?(:image_front) or create_params.has_key?(:discount_loc)
        @card_order.create_preview_front
        @card_order.create_preview_back
      end

      render json: @card_order, serializer: CardOrderSerializer

    else
      render_validation_errors(@card_order)
    end

  end

  def destroy
  end

  private

  def set_card_order
    @card_order = CardOrder.find_by(id: params[:id], shop_id: @current_shop.id)
    render_not_found if @card_order.nil?
  end

  def create_params
    params.require(:card_order).permit(
      :id,
      :shop_id,
      :type,
      :discount_pct,
      :discount_exp,
      :enabled,
      :international,
      :send_delay,
      :arrive_by,
      :customers_before,
      :customers_after,
      :status)
  end
end
