class API::BaseController < AuthenticatedController
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  rescue_from ActiveRecord::RecordNotFound, with: :not_found!

  def not_found!
    return api_error(status: 404, errors: 'Not found')
  end

  def unprocessable
    return api_error(status: 422, error: 'Unprocessable entity')
  end
end
