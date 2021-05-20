class TargetingController < BaseController
  def index; end

  def get
    service = CustomerTargetingService.new(@current_shop)
    @accepted_attrs = params[:accepted]&.permit!
    @removed_attrs = params[:removed]&.permit!
    @customers = service.find(@accepted_attrs, @removed_attrs)
    @titles = @accepted_attrs.present? ? CSV_TITLE + @accepted_attrs.keys : CSV_TITLE
    @csv = service.build_csv(@customers, @titles)
    respond_to do |f|
      f.csv { send_data @csv, filename: "customers.csv" }
      f.html { render "customer_list" }
    end
  end

  def get_filters
    render json: {filters: FILTER_OPTIONS, conditions: CONDITIONS}
  end
end
