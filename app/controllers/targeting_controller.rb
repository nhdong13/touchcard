class TargetingController < BaseController
  before_action :read_file, only: [:get_countries, :get_states, :get_country_by_state]
  attr_accessor :data
  require "axlsx"

  def index; end

  def get
    @accepted_attrs = params[:accepted]&.permit!
    @removed_attrs = params[:removed]&.permit!
    service = CustomerTargetingService.new({shop: @current_shop}, @accepted_attrs, @removed_attrs)
    csv = service.export_customer_list

    respond_to do |f|
      f.xlsx { send_data csv, filename: "customers.xlsx" }
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
