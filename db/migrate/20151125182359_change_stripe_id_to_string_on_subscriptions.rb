class ChangeStripeIdToStringOnSubscriptions < ActiveRecord::Migration[4.2]
  def change
    change_table :subscriptions do |t|
      t.remove :stripe_id
      t.string :stripe_id, null: false, index: true
    end
  end
end
