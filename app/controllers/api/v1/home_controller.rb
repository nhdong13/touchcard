class API::V1::HomeController < API::BaseController

  def index
    if @current_shop.card_templates.any?
      @current_shop.update(last_login: Time.now)
      @income = 0.00

      @follow_ups = []
      # TODO: get array of repeat orders from past card recipients (private method)

      @sent_cards = current_shop.postcards.where(sent: true);

      render json: @sent_cards, serializer: PostcardSerializer
    end
  end

  def support
  end

end
