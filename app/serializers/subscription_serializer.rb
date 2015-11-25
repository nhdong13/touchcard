class SubscriptionSerializer < ActiveModel::Serializer
  attributes :id, :quantity, :plan_id
end
