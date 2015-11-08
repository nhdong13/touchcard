class API::V1::CardTemplatesController < API::BaseController
  before_action :set_card_template, only: [:show, :update, :destroy]

  def index
    @card_templates = CardTemplate.where(shop_id: @current_shop.id)
    render @card_templates, each_serializer: CardTemplateSerializer
  end

  def show
    render json: @card_template, serializer: CardTemplateSerializer
  end

# def new
#   @card_template = template_type.new
#   render json: @card_template, serializer: CardTemplateSerializer
# end

  def create
    @card_template = CardTemplate.new(card_params)
    @card_template.shop_id = @current_shop.id
#   @card_template.text_front = "We're glad we could share our products with you. We hope you're enjoying your purchase!"
    @card_template.coupon_pct = 10
    @card_template.coupon_loc = "10.00,65.00"
    if @card_template.save
      render json: @card_template, serializer: CardTemplateSerializer
    else
      # return 422 error
      render json: { errors: @card_template.errors }, status: 422
    end

  end

# def edit
#   @card_template = CardTemplate.find_by(id: params[:id], shop_id: @current_shop.id)
#   render json: @card_template, serializer: CardTemplateSerializer
#   #@expire = Time.now + @card_template.send_delay.weeks + 2.weeks
# end

  def update
    #@card_template = CardTemplate.find_by(id: params[:id], shop_id: @current_shop.id)
    @card_template.assign_attributes(coupon_params)

    if card_params.has_key?(:image_back)
      @card_template.image_back = AwsUtils.upload_to_s3(card_params[:image_back].original_filename, card_params[:image_back].path)
    end

    if card_params.has_key?(:image_front)
      @card_template.image_front = AwsUtils.upload_to_s3(card_params[:image_front].original_filename, card_params[:image_front].path)
    end

    if @card_template.save
      if card_params.has_key?(:image_back) or card_params.has_key?(:image_front) or card_params.has_key?(:coupon_loc)
        @card_template.create_preview_front
        @card_template.create_preview_back
      end

      render json: @card_template, serializer: CardTemplateSerializer

    else

      render json: { error: @card_template.errors }, status: 422
    end

  end

  def destroy
  end

  private

  def set_card_template
    @card_template = CardTemplate.find_by(id: params[:id], shop_id: @current_shop.id)
    if @card_template.nil?
      render json: { errors: "not-found" }, status: 404
    end
  end

  def template_types
    [PostsaleTemplate, BulkTemplate]
  end

  def template_type
    params[:type].constantize if params[:type].constantize.in? template_types
  end

  def card_params
    params.require(:card_template).permit(
      :id,
      :type,
      :style,
      #:logo,
      :image_front,
      :image_back,
      #:title_front,
      #:text_front,
      :coupon_pct,
      :coupon_exp,
      :coupon_loc,
      :enabled,
      :international,
      :send_delay,
      :arrive_by,
      :customers_before,
      :customers_after,
      :status)
  end

  def coupon_params
    params.require(:card_template).permit(
      :id,
      :coupon_pct,
      :coupon_exp)
  end

end
