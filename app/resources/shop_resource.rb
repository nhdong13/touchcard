class ShopResource < JSONAPI::Resource
  has_many :charges
  has_many :card_templates
  has_many :postcards

  attributes :domain, :token, :shopify_id, :credit, :charge_id, :charge_amount, :charge_date,
    :customer_pct, :last_month, :send_next, :last_login
end
