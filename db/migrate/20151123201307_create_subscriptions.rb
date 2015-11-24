class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.integer :quantity, null: false
      t.belongs_to :plan, index: true, foreign_key: true
      t.belongs_to :shop, index: true, foreign_key: true
      t.integer :shopify_id, null: false
      t.timestamp :current_period_start, null: false
      t.timestamp :current_period_end, null: false

      t.timestamps null: false
    end
  end
end
