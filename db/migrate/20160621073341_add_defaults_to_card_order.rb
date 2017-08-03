class AddDefaultsToCardOrder < ActiveRecord::Migration
  def change
    change_column :card_orders, :send_delay, :integer, default: 0
  end
end
