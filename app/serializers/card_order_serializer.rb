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
             :tokens_used,
             :budget_used,
             :campaign_type,
             :send_date_start,
             :send_date_end,
             :front_json,
             :back_json,
             :send_continuously


  def campaign_status
    return unless object.campaign_status
    object.campaign_status.capitalize.split("_").join(" ")
  end

  def tokens_used
  end

  def campaign_type
    return "-" if object.campaign_type.nil?
    object.campaign_type.capitalize.split("_").join("-")
  end

  def budget_type
    case object.budget_type
    when "non_set"
      "-"
    when "monthly"
      object.budget_used
    end
  end

  def budget
    return "-" if object.one_off?
    case object.budget_type
    when "non_set"
      "-"
    else
      "$#{object.budget.to_i}"
    end
  end

  def schedule
    start_date = object.send_date_start&.strftime("%F %R %:z")
    end_date = object.send_date_end&.strftime("%F %R %:z")
    if start_date.blank?
      "Not Set"
    elsif object.one_off?
      start_date
    elsif object.send_continuously
      "#{start_date} &to& Ongoing"
    elsif end_date.blank?
      "Not Set"
    else
      "#{start_date} &to& #{end_date}"
    end
  end

end
