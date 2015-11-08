class ShopSerializer < ActiveModel::Serializer
  attributes :id, :shopify_id, :credit, :webhook_id, :uninstall_id, :charge_id,
    :charge_amount, :charge_date, :customer_pct, :last_month, :send_next, :last_login
end
