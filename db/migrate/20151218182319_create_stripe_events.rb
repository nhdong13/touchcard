class CreateStripeEvents < ActiveRecord::Migration
  def change
    create_table :stripe_events do |t|
      t.string :stripe_id, null: false
      t.string :status, null: false

      t.timestamps null: false
    end
  end
end
