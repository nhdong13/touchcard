class HomeController < AuthenticatedController
  before_action :current_shop

  def index
    unless current_shop.master_card == nil
      @income = 0.00

      @follow_ups = []
      # TODO: get array of repeat orders from past card recipients (private method)

      @sent_cards = current_shop.cards.where(:sent => true);
    else
      redirect_to new_master_card_path

    end
  end

  def support
  end

  private

#  def initialize_api
#    @api = ShopifyAppServices.new( { id: current_shop.id } )
#  end

  def current_shop
    @current_shop ||= Shop.find(session[:shopify])
  end

end
