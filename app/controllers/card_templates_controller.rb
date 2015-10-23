class CardTemplatesController < AuthenticatedController
  before_action :current_shop
  attr_accessor :image_remove

  def show
    @card_template = CardTemplate.find(params[:id])
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
    @card_template = CardTemplate.find(params[:id])
    @expire = Time.now + @card_template.shop.send_delay.weeks + 2.weeks
  end

  def update
    if params[:commit] == "Save"
      puts "coupon confirm!"
      @card_template = CardTemplate.find(params[:id])
      @card_template.update_attributes(coupon_params)

      respond_to do |format|
        format.html { redirect_to edit_polymorphic_path(@card_template) }
        format.json { render json: @card_template }
        format.js   {}
      end
    else
      #TODO: Refactor S3 upload stuff
      @card_template = CardTemplate.find(params[:id])
      @expire = Time.now + @card_template.send_delay.weeks + 2.weeks

      if card_params.has_key?(:style)
        update_tamplate()
        render 'edit'
      else
        @current_shop.new_sess
        @card_template.title_front = card_params[:title_front]
        @card_template.text_front = card_params[:text_front]
        @card_template.coupon_pct = card_params[:coupon_pct]
        @card_template.coupon_exp = card_params[:coupon_exp]
        @card_template.coupon_loc = card_params[:coupon_loc]

        if card_params.has_key?(:image_back)
          image_back_key = card_params[:image_back].original_filename
          asset_upload(card_params[:image_back], image_back_key, "image_back")
        end

        if card_params.has_key?(:image_front)
          image_front_key = card_params[:image_front].original_filename
         asset_upload(card_params[:image_front], image_front_key, "image_front")
        end

        if card_params.has_key?(:logo)
          logo_key = card_params[:logo].original_filename
          asset_upload(card_params[:logo], logo_key, "logo")
        end

        begin
          @card_template.save!
          @card_template.create_preview_front
          @card_template.create_preview_back
          flash[:success] = "Card template updated"
          render 'show'
        rescue
          render 'edit'
        end
      end
    end
  end

  def destroy
  end

  def style_switch
    @card_template = CardTemplate.find(params[:id])
    if @card_template.style == "thank you"
      @card_template.style = "coupon"
    else
      @card_template.style = "thank you"
    end

    @card_template.save!

    redirect_to edit_card_template_path(@card_template)
  end

  def image_remove
    @card_template = CardTemplate.find(params[:id])
    case params[:image_remove]
    when "front"
      @card_template.image_front = nil
    when "back"
      @card_template.image_back = nil
    when "logo"
      @card_template.logo = nil
    end

    @card_template.save!
    #render :nothing => true
    redirect_to edit_card_template_path(@card_template)
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

  def template_types
    [PostsaleTemplate, BulkTemplate]
  end

  def template_type
    params[:type].constantize if params[:type].in? template_types
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
      @card_template.style = "thank you"
    else
      @card_template.style = "coupon"
    end
    @card_template.save!
  end

  def asset_upload(file, image_key, image_type)
    # Initialize S3 bucket
    s3 = Aws::S3::Client.new
    obj = S3_BUCKET.object(image_key)
    obj.upload_file(file.path)

    # Initialize S3 bucket
    s3.put_object_acl(bucket: ENV['S3_BUCKET_NAME'], key: image_key, acl: 'public-read')

      # Image type case statement
      case image_type
      when "logo"
        @card_template.logo = obj.public_url.to_s
      when "image_front"
        @card_template.image_front = obj.public_url.to_s
      when "image_back"
        @card_template.image_back = obj.public_url.to_s
      end
  end

  def current_shop
    @current_shop ||= Shop.find(session[:shopify])
  end
end
