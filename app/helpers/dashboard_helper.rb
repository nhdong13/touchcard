module DashboardHelper
  def postcard_status(postcard)
    if postcard.canceled?
      "Canceled"
    elsif postcard.sent?
      "Sent on #{postcard.date_sent.to_date}"
    else
      "Sending #{postcard.send_date.to_date}"
    end
  end
end
