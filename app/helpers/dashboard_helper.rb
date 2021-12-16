module DashboardHelper
  def postcard_status(postcard)
    if postcard.canceled?
      "Canceled"
    elsif postcard.sent?
      "Sent on #{postcard&.date_sent&.to_date}"
    else
      "Sending #{postcard&.send_date&.to_date}"
    end
  end

  def ad_spend_postcards postcards
    today = Time.now
    postcards.filter do |pc|
      false
      if pc.discount_code.present?
        true if pc.discount_exp_at < today
      else
        true if pc.date_sent.present? && pc.date_sent.beginning_of_day < today + 21.days
      end
    end
  end
end
