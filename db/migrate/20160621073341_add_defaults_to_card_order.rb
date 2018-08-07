class AddDefaultsToCardOrder < ActiveRecord::Migration[4.2]
  def change
    change_column :card_orders, :send_delay, :integer, default: 0
  end
end
