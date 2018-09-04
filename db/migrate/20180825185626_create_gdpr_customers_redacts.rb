class CreateGdprCustomersRedacts < ActiveRecord::Migration
  def change
    create_table :gdpr_customers_redacts do |t|
      t.bigint :shop_shopify_id
      t.string :shop_domain
      t.bigint :customer_shopify_id
      t.string :customer_email
      t.string :customer_phone
      t.bigint :orders_to_redact, array:true, default: []

      t.timestamps
    end
  end
end
