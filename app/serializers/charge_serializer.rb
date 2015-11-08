class ChargeSerializer < ActiveModel::Serializer
  attributes :id, :shopify_id, :card_template_id, :amount, :recurring, :status, :shopify_redirect, :last_page

  has_one :shop, embed: :ids
end
