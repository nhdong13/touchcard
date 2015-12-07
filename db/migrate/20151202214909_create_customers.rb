class CreateCustomers < ActiveRecord::Migration
  def change
    create_table :customers do |t|
      t.integer :shopify_id, null: false, limit: 8
      t.string :first_name
      t.string :last_name
      t.string :email
      t.boolean :verified_email
      t.integer :total_spent
      t.boolean :tax_exempt
      t.text :tags
      t.string :state
      t.integer :orders_count
      t.text :note
      t.text :last_order_name
      t.string :last_order_id
      t.boolean :accepts_marketing

      t.timestamps null: false
    end
    add_index :customers, :shopify_id, unique: true
  end
end
