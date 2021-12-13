# This migration is used for convert the old token into new dollar credit
class AddValueToSubscriptions < ActiveRecord::Migration[6.1]
  def change
    add_column :subscriptions, :value, :float, default: 0
  end
end
