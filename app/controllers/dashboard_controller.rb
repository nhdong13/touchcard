class DashboardController < BaseController
  def index
    @current_page = params[:page].present? ? params[:page] : 1
    @postcards = @current_shop.postcards.where(paid: true)
      .or(@current_shop.postcards.where(canceled: true))
      .where(error: nil)
      .order(created_at: :desc)
      .page(@current_page)
      .per(20)
  end

  def cancel_postcard
    @postcard = @current_shop.postcards.find(params[:id])
    @postcard.cancel
  end
end
