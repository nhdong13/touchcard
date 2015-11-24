class ShopSerializer < ActiveModel::Serializer
  attributes :id, :credit, :subscription_id, :is_card_registered

  def is_card_registered
    object.stripe_customer_id.present?
  end
end
