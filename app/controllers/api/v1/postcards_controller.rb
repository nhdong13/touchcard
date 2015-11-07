class API::V1::PostcardsController < BaseController

  def index
    @postcards = @current_shop.postcards
    render json: @postcards, serializer: PostcardSerializer
  end

  def new
  end

  def create
  end

  def show
  end

  def edit
  end

  def update
  end

  def destroy
  end

end
