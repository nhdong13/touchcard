class NamespaceShopifyColumns < ActiveRecord::Migration[4.2]
  def change
    rename_column :postcards, :order_id, :triggering_shopify_order_id
    rename_column :postcards, :customer_id, :shopify_customer_id
  end
end
