class TargetingController < BaseController
  def index; end

  def get
    service = CustomerTargetingService.new(@current_shop)
    @accepted_attrs = params[:accepted]&.permit!
    @removed_attrs = params[:removed]&.permit!
    @customers = service.find(@accepted_attrs, @removed_attrs)
    @titles = @accepted_attrs ? ["full_name"] + @accepted_attrs[:filter] : ["full_name"]
    @csv = service.build_csv(@customers, @titles)
    respond_to do |f|
      f.csv { send_data @csv, filename: "customers.csv" }
      f.html { render "customer_list" }
    end
  end
end
