class AddSendDelayToCardOrders < ActiveRecord::Migration[6.1]
  def change
    add_column :card_orders, :send_delay, :integer, default: 0
  end
end
