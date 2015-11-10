class API::V1::CardTemplatesController < API::BaseController
  before_action :set_card_template, only: [:show, :update, :destroy]

  def index
    @card_templates = CardTemplate.where(shop_id: @current_shop.id)
    render @card_templates, each_serializer: CardTemplateSerializer
  end

  def show
    render json: @card_template, serializer: CardTemplateSerializer
  end

  def create
    @card_template = CardTemplate.new(create_params)
    if @card_template.save
      render json: @card_template, serializer: CardTemplateSerializer
    else
      # return 422 error
      puts @card_template.errors.full_messages
      puts @card_template.shop_id
      render json: { errors: @card_template.errors }, status: 422
    end

  end

  def update
    @card_template.assign_attributes(discount_params)

    if create_params.has_key?(:image_back)
      @card_template.image_back = AwsUtils.upload_to_s3(create_params[:image_back].original_filename, create_params[:image_back].path)
    end

    if create_params.has_key?(:image_front)
      @card_template.image_front = AwsUtils.upload_to_s3(create_params[:image_front].original_filename, create_params[:image_front].path)
    end

    if @card_template.save
      if create_params.has_key?(:image_back) or create_params.has_key?(:image_front) or create_params.has_key?(:discount_loc)
        @card_template.create_preview_front
        @card_template.create_preview_back
      end

      render json: @card_template, serializer: CardTemplateSerializer

    else
      render_validation_errors(@card_template)
    end

  end

  def destroy
  end

  private

  def set_card_template
    @card_template = CardTemplate.find_by(id: params[:id], shop_id: @current_shop.id)
    render_not_found if @card_template.nil?
  end

  def create_params
    params.require(:card_template).permit(
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
