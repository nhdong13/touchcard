class HomeController < AuthenticatedController
  def index
    unless current_shop.cards.count == 0
      @cards = current_shop.cards
    else
      redirect_to card_index_path
    end
  end

  private

#  def initialize_api
#    @api = ShopifyAppServices.new( { id: current_shop.id } )
#  end

  def current_shop
    @current_shop ||= Shop.find(session[:shopify])
  end

end
