class CardController < ApplicationController

  def index
    @cards = current_shop.cards
  end

  def new
    @card = Card.new
  end

  def create
    @card = Card.new(card_params)

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
    params.require(:card).permit(:template, :image_front, :image_back, :text_front, :text_back)
  end

#  def initialize_api
#    @api = ShopifyAppServices.new( { id: current_shop.id } )
#  end

  def current_shop
    @current_shop ||= Shop.find(session[:shopify])
  end

end
