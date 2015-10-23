class HomeController < AuthenticatedController
  before_action :current_shop

  def index
    if current_shop.card_templates.any?
      @current_shop.update(last_login: Time.now)
      @income = 0.00

      @follow_ups = []
      # TODO: get array of repeat orders from past card recipients (private method)

      @sent_cards = current_shop.postcards.where(:sent => true);
    else
      redirect_to new_postsale_template_path
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
