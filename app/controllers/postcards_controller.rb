class CardsController < AuthenticatedController
  before_action :current_shop

  def index
    @cards = current_shop.cards
  end

  def new
    @card = Card.new
  end

  def create
    if params.has_key?(:image_front)
      image_front_key = params[:image_front].original_filename
      #@card = Card.new(card_params)

      # Initialize S3 bucket
      obj = S3_BUCKET.object(image_front_key)
      obj.upload_file(params[:image_front].path)

      key = "assets\/" + image_front_key
      src_url = "https://" + S3_BUCKET + ".s3.amazonaws.com/front_images/" + image_front_key
      theme_id = ShopifyAPI::Theme.where(:role => "main")[0].id

      begin
        ShopifyAPI::Asset.create({:key => key, :src => src_url, :theme_id => theme_id})
        S3_BUCKET.objects.delete(image_front_key)
      rescue
        puts "There was a problem with the uplaod"
      end
    end


    # Validate with save
    if @card.save!
      # TODO: Redirect them to the card manage page
    else
      render 'new'
    end
  end

  def show
    @card = Card.find(params[:id])
  end

  def edit
    @card = Card.find(params[:id])
  end

  def update
    @card = Card.find(params[:id])
    if @card.update_attributes(card_params)
      # flash[:success] = "Card updated!"
      redirect_to root_url
    else
      render 'edit'
    end
  end

  def destroy
    @card = Card.find(params[:id])
    @card.destroy
    # flash[:warning] = "The card has been deleted"
    redirect_to root_url
  end

  private

  def card_params
    params.require(:card).permit(:template, :image_front, :image_back, :text_front, :text_back, :coupon_pct, :coupon_exp)
  end

#  def initialize_api
#    @api = ShopifyAppServices.new( { id: current_shop.id } )
#  end

  def current_shop
    @current_shop ||= Shop.find(session[:shopify])
  end

end
