class CreateLineItems < ActiveRecord::Migration
  def change
    create_table :line_items do |t|
      t.belongs_to :order, index: true, foreign_key: true, null: false
      t.integer :fulfillable_quantity
      t.string :fulfillment_service
      t.string :fulfillment_status
      t.integer :grams
      t.integer :shopify_id, null: false, limit: 8, unique: true
      t.string :price
      t.integer :product_id, limit: 8
      t.integer :quantity
      t.boolean :requires_shipping
      t.string :sku
      t.string :title
      t.integer :variant_id, limit: 8
      t.string :variant_title
      t.string :vendor
      t.string :name, null: false
      t.boolean :gift_card
      t.boolean :taxable
      t.string :total_discount

      t.timestamps null: false
    end
  end
end
