class ChargeSerializer < ActiveModel::Serializer
  attributes :id, :shopify_id, :amount, :recurring, :status, :shopify_redirect, :last_page

  has_one :shop, embed: :ids
end
