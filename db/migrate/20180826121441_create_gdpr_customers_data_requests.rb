class CreateGdprCustomersDataRequests < ActiveRecord::Migration[4.2]
  def change
    create_table :gdpr_customers_data_requests do |t|
      t.bigint :shop_shopify_id
      t.string :shop_domain
      t.bigint :customer_shopify_id
      t.string :customer_email
      t.string :customer_phone
      t.bigint :orders_requested, array:true, default: []

      t.timestamps null: false
    end
  end
end
