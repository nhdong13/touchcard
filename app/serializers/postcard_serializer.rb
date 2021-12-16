class PostcardSerializer < ActiveModel::Serializer
  attributes :id,
             :send_date,
             :date_sent,
             :sent,
             :canceled,
             :full_name,
             :city,
             :state,
             :country,
             :campaign_name,


  def send_date
    return unless object.send_date
    object&.send_date&.to_date
  end

  def date_sent
    return unless object.date_sent
    object&.date_sent&.to_date
  end

  def full_name
    return unless object.customer
    object.customer.full_name
  end

  def city
    return unless object.city
    object.city
  end

  def state
    return unless object.state
    object.state
  end

  def country
    return unless object.country
    object.country
  end 
  
  def campaign_name
    return unless object.card_order
    if object.card_order.archived
      "(Deleted) #{object.card_order.campaign_name}"
    else
      object.card_order.campaign_name
    end
  end
end
