class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.integer :shopify_id, null: false, index: { unique: true }, limit: 8
      t.string :browser_ip
      t.text :discount_codes
      t.string :financial_status
      t.string :fulfillment_status
      t.text :tags
      t.text :landing_site
      t.text :referring_site
      t.integer :total_discounts
      t.integer :total_line_items_price
      t.integer :total_price, null: false
      t.integer :total_tax, null: false
      t.string :processing_method
      t.timestamp :processed_at
      t.belongs_to :customer, index: true, foreign_key: true
      t.integer :billing_address_id, index: true
      t.integer :shipping_address_id, index: true
      t.timestamps null: false
      t.belongs_to :postcard, index: true, foreign_key: true
    end
    add_foreign_key :orders, :addresses, column: :billing_address_id
    add_foreign_key :orders, :addresses, column: :shipping_address_id
  end
end
