class Api::BaseController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  before_action :require_auth

  def require_auth
    return render_authorization_error if session[:shopify].nil?
    @current_shop ||= Shop.find(session[:shopify])
  end

  def render_authorization_error
    render json: { errors: "Forbidden"}, status: 401
  end

  def render_not_found
    render json: { errors: "not-found" }, status: 404
  end

  def render_validation_errors(model)
    render json: { error: model.errors }, status: 422
  end
end
