class CreateCheckouts < ActiveRecord::Migration
  def change
    create_table :checkouts do |t|
      t.integer :shopify_id, null: false, index: { unique: true }, limit: 8
      t.references :shop, index: true, foreign_key: true
      t.references :customer, index: true, foreign_key: true
      t.string :abandoned_checkout_url, null: false
      t.string :cart_token, null: false
      t.datetime :closed_at
      t.datetime :completed_at
      t.string :token, null: false
      t.decimal :total_price, null: false

      t.timestamps null: false
    end
  end
end
