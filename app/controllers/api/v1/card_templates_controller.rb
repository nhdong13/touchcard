class API::V1::CardTemplatesController < BaseApiController
  before_action :set_card_template, only: [:show, :update, :destroy]

  def index
    @card_templates = CardTemplate.where(shop_id: @current_shop.id)
    render @card_templates, include: '*'
  end

  def show
  end

  def new
    @card_template = template_type.new
    render @card_template
  end

  def create
    @card_template = template_type.new(new_params)
    @card_template.shop_id = params[:shop_id]
    @card_template.title_front = "Thank You!"
    @card_template.text_front = "We're glad we could share our products with you. We hope you're enjoying your purchase!"
    @card_template.coupon_pct = 10
    @card_template.coupon_loc = "10.00,65.00"

    render @card_template, include: '*'
  end

  def edit
    @card_template = CardTemplate.find_by(id: params[:id], shop_id: @current_shop.id)
    @expire = Time.now + @card_template.send_delay.weeks + 2.weeks
  end

  def update
    if params[:commit] == "Save"
      puts "coupon confirm!"
      @card_template.update_attributes(coupon_params)

      respond_to do |format|
        format.html { redirect_to edit_polymorphic_path(@card_template) }
        format.json { render json: @card_template }
        format.js   {}
      end

    else
      #TODO: Refactor S3 upload stuff
      @expire = Time.now + @card_template.send_delay.weeks + 2.weeks

      # TODO: Refactor with params[:commit]
      if card_params.has_key?(:style)
        update_style()
        render 'edit'
      else
        @card_template.title_front  = card_params[:title_front]
        @card_template.text_front   = card_params[:text_front]
        @card_template.coupon_pct   = card_params[:coupon_pct]
        @card_template.coupon_exp   = card_params[:coupon_exp]
        @card_template.coupon_loc   = card_params[:coupon_loc]

        if card_params.has_key?(:logo)
          @card_template.logo = AwsUtils.upload_to_s3(card_params[:logo].original_filename, card_params[:logo].path)
        end

        if card_params.has_key?(:image_back)
          @card_template.logo = AwsUtils.upload_to_s3(card_params[:image_back].original_filename, card_params[:image_back].path)
        end

        if card_params.has_key?(:image_front)
          @card_template.logo = AwsUtils.upload_to_s3(card_params[:image_front].original_filename, card_params[:image_front].path)
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

  def bulk_send
    # params: :shop_id, :card_template_id, :amount, :last_page
    @charge = @current_shop.charge.create(amount: params[:amount], recurring: false, status: "new", last_page: params[:last_page])
    @bulk_template = BulkTemplate.find(params[:card_template_id])

    # Create the charge in Shopify
    shopify_charge = @current_shop.bulk_charge(@charge.amount)

    # Set the charge id in the bulk_template
    @bulk_template.transaction_id = shopify_charge.id

    # Return the confirmation URL
    shopify_charge.confirmation_url

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
