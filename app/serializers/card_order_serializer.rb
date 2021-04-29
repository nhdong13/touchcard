class CardOrderSerializer < ActiveModel::Serializer
  attributes :id,
             :campaign_name,
             :status,
             :campaign_status,
             :budget,
             :budget_update,
             :budget_type,
             :type,
             :enabled,
             :schedule,
             :send_date_start,
             :tokens_used,
             :credits


  def campaign_status
    return unless object.campaign_status
    object.campaign_status.capitalize
  end

  def tokens_used

  end

  def budget_type
    case object.budget_type
    when "non_set"
      "Non set"
    when "monthly"
      "Monthly"
    when "lifetime"
      "Lifetime"
    end
  end

  def budget
    case object.budget_type
    when "non_set"
      ""
    else
      object.budget
    end
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
