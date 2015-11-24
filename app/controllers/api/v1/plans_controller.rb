class Api::V1::PlansController < ApplicationController
  before_action :set_plan, only: [:subscription]
  def show
    render json: @plan
  end

  def index
    render json: Plan.all
  end

  private

  def set_plan
    @plan = Plan.find_by(id: params[:id])
    render_not_found unless @plan
  end
end
