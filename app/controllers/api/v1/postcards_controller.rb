class API::V1::PostcardsController < BaseApiController

  def index
    @postcards = @current_shop.postcards
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
