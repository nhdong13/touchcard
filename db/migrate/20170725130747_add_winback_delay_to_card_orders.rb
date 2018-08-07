class AddWinbackDelayToCardOrders < ActiveRecord::Migration[4.2]
  def change
    add_column :card_orders, :winback_delay, :integer
  end
end
