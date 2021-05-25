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

  def get_countries
    file = File.open("./public/countries.json")
    data = JSON.load(file)
    file.close
    res = data.map{|item| {id: item["code2"], label: item["name"]}}
    render json: res
  end

  def get_states
    file = File.open("./public/countries.json")
    data = JSON.load(file)
    file.close
    res = data.select{|item| item["code2"] == params[:country]}
    res = res[0]["states"].map{|state| {id: state["code"], label: state["name"]}} if res.present?
    render json: res
  end
end
