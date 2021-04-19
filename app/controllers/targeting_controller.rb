class TargetingController < BaseController
  def index; end

  def get
    service = CustomerTargetingService.new(@current_shop)
    @permited = params.permit(:accepted, :removed)
    @customers = service.find(@permited[:accepted], @permited[:removed])
    @csv = ExportCsvService.new(@customers, []).perform
    respond_to do |f|
      f.csv { send_data @csv, filename: "customers.csv" }
      f.html { render "customer_list" }
    end
  end
end
