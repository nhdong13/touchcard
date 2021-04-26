class CardOrderSerializer < ActiveModel::Serializer
  attributes :id,
             :campaign_name,
             :status,
             :campaign_status,
             :budget,
             :type,
             :enabled,
             :schedule,
             :send_date_start


  def campaign_status
    return unless object.campaign_status
    object.campaign_status.capitalize
  end

  def budget
    return "Not set" unless object.budget
    object.budget
  end

  def schedule
    case object.campaign_status
    when "draft"
      "Not set"
    when "sending"
      "#{DatetimeService.new(object.send_date_start).to_date} - Ongoing"
    when "paused"
      "#{DatetimeService.new(object.send_date_start).to_date} - #{DatetimeService.new(object.send_date_end).to_date}"
    else
      "Not set"
    end
  end
end
