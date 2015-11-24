class CreatePlans < ActiveRecord::Migration
  def change
    create_table :plans do |t|
      t.integer :amount, null: false
      t.string :interval, default: 'month', null: false
      t.string :name, null: false
      t.string :currency, default: 'usd', null: false
      t.integer :interval_count, default: 1, null: false
      t.boolean :on_stripe, default: false, null: false

      t.integer :trial_period_days
      t.text :statement_descriptor

      t.timestamps null: false
    end
  end
end
