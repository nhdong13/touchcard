class MasterCardsController < AuthenticatedController
  before_action :current_shop
  attr_accessor :image_remove

  def show
    @master_card = MasterCard.find(params[:id])
  end

  def new
    @master_card = MasterCard.new
  end

  def create
    @master_card = MasterCard.new(new_params)
    @master_card.shop_id = @current_shop.id
    @master_card.title_front = "Thank You!"
    @master_card.text_front = "We're glad we could share our products with you. We hope you're enjoying your purchase!"
    if @master_card.save!
      redirect_to edit_master_card_path(:id => @master_card.id)
    else
      render 'new'
    end
  end

  def edit
    @master_card = MasterCard.find(params[:id])
  end

  def update
    #TODO: Refactor S3 upload stuff
    @master_card = MasterCard.find(params[:id])

    if card_params.has_key?(:template)
      update_tamplate()
      render 'edit'
    else
      @current_shop.new_sess
      @master_card.title_front = card_params[:title_front]
      @master_card.text_front = card_params[:text_front]
      @master_card.coupon_pct = card_params[:coupon_pct]
      @master_card.coupon_exp = card_params[:coupon_exp]

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
        @master_card.save!
       # @master_card.create_preview_front
       # @master_card.create_preview_back
        flash[:success] = "Settings updated"
        render 'show'
      rescue
        render 'edit'
      end
    end
  end

  def destroy
  end

  def template_switch
    @master_card = MasterCard.find(params[:id])
    if @master_card.template == "thank you"
      @master_card.template = "coupon"
    else
      @master_card.template = "thank you"
    end

    @master_card.save!

    redirect_to edit_master_card_path(@master_card)
  end

  def image_remove
    @master_card = MasterCard.find(params[:id])
    case params[:image_remove]
    when "front"
      @master_card.image_front = nil
    when "back"
      @master_card.image_back = nil
    when "logo"
      @master_card.logo = nil
    end

    @master_card.save!
    #render :nothing => true
    redirect_to edit_master_card_path(@master_card)
  end

  private

  def new_params
    params.permit(:template)
  end

  def card_params
    params.require(:master_card).permit(
      :id,
      :template,
      :logo,
      :image_front,
      :image_back,
      :title_front,
      :text_front,
      :text_back,
      :coupon_pct,
      :coupon_exp,
      :coupon_loc,
      :image_remove)
  end

  def update_template
    if card_params[:template].downcase.include?("thank you")
      @master_card.template = "thank you"
    else
      @master_card.template = "coupon"
    end
    @master_card.save!
  end

  def asset_upload(file, image_key, image_type)
    # Initialize S3 bucket
    s3 = Aws::S3::Client.new
    obj = S3_BUCKET.object(image_key)
    obj.upload_file(file.path)

    # Initialize S3 bucket
    s3.put_object_acl(bucket: ENV['S3_BUCKET_NAME'], key: image_key, acl: 'public-read')

    # Setup variables for Shopify theme asset creation
    key = "assets\/" + image_key
    src_url = "https://" + ENV['S3_BUCKET_NAME'].to_s + ".s3.amazonaws.com/" + image_key
    theme_id = ShopifyAPI::Theme.where(:role => "main")[0].id

    begin
      image_asset = ShopifyAPI::Asset.create({:key => key, :src => src_url, :theme_id => theme_id})

      # Image type case statement
      case image_type
      when "logo"
        @master_card.logo = image_asset.public_url
      when "image_front"
        @master_card.image_front = image_asset.public_url
      when "image_back"
        @master_card.image_back = image_asset.public_url
      end

      S3_BUCKET.objects.delete(image_key)
    rescue
      puts "There was a problem with the uplaod"
    end
  end

  def current_shop
    @current_shop ||= Shop.find(session[:shopify])
  end
end
