class DashboardController < BaseController
  def index
    @postcards = @current_shop.postcards.where(paid: true).order(updated_at: :desc).limit(20)
  end
end
