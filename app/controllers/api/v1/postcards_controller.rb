class API::V1::PostcardsController < API::BaseController
  before_action :set_postcard, only: [:show, :update, :destoy]

  def index
    @postcards = @current_shop.postcards
    render json: @postcards, each_serializer: PostcardSerializer
  end

  def create
  end

  def show
    render json: @postcard, serializer: PostcardSerializer
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

  def set_postcard
    @postcard= Postcard.find_by(id: params[:id])
    if @postcard.nil? or @postcard.shop.id != @current_shop.id
      render json: { errors: "not-found" }, status: 404
    end
  end

end
