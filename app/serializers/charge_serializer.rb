class ChargeSerializer < ActiveModel::Serializer
  attributes :id, :recurring, :card_order_id, :amount, :status,
   :shopify_redirect, :last_page
end
