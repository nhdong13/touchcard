class AddWinbackDelayToCardOrders < ActiveRecord::Migration
  def change
    add_column :card_orders, :winback_delay, :integer
  end
end
