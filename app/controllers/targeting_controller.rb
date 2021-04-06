class TargetingController < BaseController
  def index; end

  def get
    service = CustomerTargetingService.new(@current_shop)
    @customers = service.find(params[:accepted], params[:removed])
    render "customer_list"
  end
end
