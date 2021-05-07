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
             :credits,
             :campaign_type,
             :send_date_start
             :send_date_end


  def campaign_status
    return unless object.campaign_status
    object.campaign_status.capitalize
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
      object.credits
    end
  end

  def budget
    return "-" if object.one_off?
    case object.budget_type
    when "non_set"
      "-"
    else
      "$#{object.budget}"
    end
  end

  def schedule
    result = "-"
    start_date = DatetimeService.new(object.send_date_start).to_date
    end_date = DatetimeService.new(object.send_date_end).to_date
    if object.one_off?
      if object.send_date_end
        result = "#{start_date} - #{end_date}"
      else
        result = "#{start_date}"
      end
    else
      case object.campaign_status
      when "draft"
        result = "Not set"
      when "sending"
        result = "#{start_date} - Ongoing"
      when "paused"
        result = "#{start_date} - #{end_date}"
      else
        result = "Not set"
      end
    end
    result
  end
end
