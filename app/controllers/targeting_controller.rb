class TargetingController < BaseController
  before_action :read_file, only: [:get_countries, :get_states, :get_country_by_state]
  attr_accessor :data

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
    res = data.map{|item| {id: item["iso3"], label: item["name"]}}
    render json: res
  end

  def get_states
    res = data.select{|item| item["iso3"] == params[:country]}
    res = res[0]["states"].map{|state| {id: state["id"], label: state["name"]}} if res.present?
    render json: res
  end

  def get_country_by_state
    res = data.select{|item| item["states"].map{|state| state["id"]}.index(params[:state].to_i).present?}
    render json: {result: res.present? ? res[0]["iso3"] : nil}
  end

  private
  def read_file
    file = File.open("./public/countries.json")
    @data = JSON.load(file)
    file.close
  end
end
