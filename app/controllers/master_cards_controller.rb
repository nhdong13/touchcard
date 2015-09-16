class MasterCardsController < ApplicationController
  before_action :current_shop
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
    @master_card.text_front = "We're glad we could share out products with you. We hope you're enjoying your purchase!"
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
    unless params.has_key?(:template)
      s3 = Aws::S3::Client.new
      if card_params.has_key?(:image_back)
        image_back_key = card_params[:image_back].original_filename

        # Initialize S3 bucket
        obj = S3_BUCKET.object(image_back_key)
        obj.upload_file(card_params[:image_back].path)

        # Set access on S3 to public
        s3.put_object_acl(bucket: ENV['S3_BUCKET_NAME'], key: image_back_key, acl: 'public-read')

        # Setup variables for Shopify theme asset creation
        key = "assets\/" + image_back_key
        src_url = obj.public_url.to_s
        @current_shop.new_sess
        theme_id = ShopifyAPI::Theme.where(:role => "main")[0].id

        begin
          image_back = ShopifyAPI::Asset.create({:key => key, :src => src_url, :theme_id => theme_id})
          @master_card.image_back = image_back.public_url
          S3_BUCKET.objects.delete(image_back_key)
        rescue
          puts "There was a problem with the uplaod"
        end
      end

      if card_params.has_key?(:image_front)
        image_front_key = card_params[:image_front].original_filename

        # Initialize S3 bucket
        obj = S3_BUCKET.object(image_front_key)
        obj.upload_file(card_params[:image_front].path)

        # Initialize S3 bucket
        s3.put_object_acl(bucket: ENV['S3_BUCKET_NAME'], key: image_front_key, acl: 'public-read')

        # Setup variables for Shopify theme asset creation
        key = "assets\/" + image_front_key
        src_url = "https://" + ENV['S3_BUCKET_NAME'].to_s + ".s3.amazonaws.com/" + image_front_key
        theme_id = ShopifyAPI::Theme.where(:role => "main")[0].id

        begin
          image_front = ShopifyAPI::Asset.create({:key => key, :src => src_url, :theme_id => theme_id})
          @master_card.image_front = image_front.public_url
          S3_BUCKET.objects.delete(image_front_key)
        rescue
          puts "There was a problem with the uplaod"
        end
      end

      if card_params.has_key?(:logo)
        logo_key = card_params[:logo].original_filename

        # Initialize S3 bucket
        obj = S3_BUCKET.object(logo_key)
        obj.upload_file(card_params[:logo].path)

        # Initialize S3 bucket
        s3.put_object_acl(bucket: ENV['S3_BUCKET_NAME'], key: logo_key, acl: 'public-read')

        # Setup variables for Shopify theme asset creation
        key = "assets\/" + logo_key
        src_url = "https://" + ENV['S3_BUCKET_NAME'].to_s + ".s3.amazonaws.com/" + logo_key
        theme_id = ShopifyAPI::Theme.where(:role => "main")[0].id

        begin
          logo = ShopifyAPI::Asset.create({:key => key, :src => src_url, :theme_id => theme_id})
          @master_card.logo = logo.public_url
          S3_BUCKET.objects.delete(logo_key)
        rescue
          puts "There was a problem with the uplaod"
        end
      end

      begin @master_card.save!
        flash[:success] = "Settings updated"
        render 'show'
      rescue
        render 'edit'
      end
    else
      if params[:template].downcase.include?("thank you")
        @master_card.template = "thank you"
      else
        @master_card.template = "coupon"
      end
      @master_card.save!
      @master_card.create_preview_front
      @master_card.create_preview_back
      render 'edit'
    end
  end



  def destroy
  end

  private

  def new_params
    params.permit(:template)
  end

  def card_params
    params.require(:master_card).permit(
      :template,
      :logo,
      :image_front,
      :image_back,
      :title_front,
      :text_front,
      :text_back,
      :coupon_pct,
      :coupon_exp,
      :coupon_loc)
  end

  def current_shop
    @current_shop ||= Shop.find(session[:shopify])
  end
end
