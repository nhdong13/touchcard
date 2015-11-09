class CardTemplatesController < AuthenticatedController
  attr_accessor :image_remove
  before_action :set_card_template, only: [:update, :destroy, :show]

  def show
  end

  def new
    @card_template = template_type.new
  end

  def create
    @card_template = template_type.new(new_params)
    @card_template.shop_id = @current_shop.id
    @card_template.title_front = "Thank You!"
    @card_template.text_front = "We're glad we could share our products with you. We hope you're enjoying your purchase!"
    @card_template.coupon_pct = 10
    @card_template.coupon_loc = "10.00,65.00"
    if @card_template.save!
      redirect_to edit_polymorphic_path(@card_template)
    else
      render 'new'
    end
  end

  def edit
    @expire = Time.now + @card_template.send_delay.weeks + 2.weeks
  end

  def update
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
      render 'show'

    else
      render 'edit'
    end
  end

  def destroy
  end

  def coupon_confirm
    puts "coupon confirm!"
    @card_template = CardTemplate.find(params[:id])
    @card_template.update_attributes(coupon_params)

    respond_to do |format|
      format.html { redirect_to edit_card_template_path(@card_template) }
      format.json { render json: @card_template }
      format.js   {}
    end
  end

  private

  def set_card_template
    @card_template = CardTemplate.find_by(id: params[:id], shop_id: @current_shop.id)
    if @card_template.nil?
      # TODO: Add 404 page here
      puts "404 here"
    end
  end

  def template_types
    [PostsaleTemplate, BulkTemplate]
  end

  def template_type
    params[:type].constantize if params[:type].constantize.in? template_types
  end

  def new_params
    params.permit(:style)
  end

  def card_params
    params.require(:card_template).permit(
      :id,
      :type,
      :style,
      :logo,
      :image_front,
      :image_back,
      :title_front,
      :text_front,
      :coupon_pct,
      :coupon_exp,
      :coupon_loc,
      :enabled,
      :international,
      :send_delay,
      :arrive_by,
      :customers_before,
      :customers_after,
      :archive,
      :image_remove)
  end

  def coupon_params
    params.require(:card_template).permit(
      :id,
      :coupon_pct,
      :coupon_exp)
  end

  def update_style
    if card_params[:style].downcase.include?("thank you")
      @card_template.update(:style => "thank you")
    else
      @card_template.update(:style => "coupon")
    end
  end

end
