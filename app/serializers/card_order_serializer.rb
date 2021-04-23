class CardOrderSerializer < ActiveModel::Serializer
  attributes :id,
             :name,
             :status,
             :campaign_status,
             :budget,
             :type,
             :enabled

  def campaign_status
    return unless object.campaign_status
    object.campaign_status.capitalize
  end

end
