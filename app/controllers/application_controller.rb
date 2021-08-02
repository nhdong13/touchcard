class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :allow_iframe_requests

  def download_csv_template
    send_file(
      "#{Rails.root}/public/csv_template.csv",
      filename: "csv_template.csv",
      type: "text/csv"
    )
  end

  private
  def allow_iframe_requests
    response.headers.delete('X-Frame-Options')
  end
end
