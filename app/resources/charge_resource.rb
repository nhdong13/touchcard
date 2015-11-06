class ChargeResource < JSONAPI::Resource
  belongs_to :shop

  attributes :shopify_id, :amount, :recurring, :status, :shopify_redirect, :last_page
end
