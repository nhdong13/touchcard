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
             :back_json


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
      if object.send_continuously
        if object.send_date_start
          result = "#{start_date} - Ongoing"
        else
          result = "Not set"
        end
      else
        if object.send_date_start && object.send_date_end
          result = "#{start_date} - #{end_date}"
        else
          result = "Not set"
        end
      end
    end
    result
  end
end
