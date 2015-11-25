class ShopSerializer < ActiveModel::Serializer
  attributes :id, :credit, :subscription_ids, :is_card_registered
end
