class ChangeDefaultSendDelayForCardOrders < ActiveRecord::Migration[5.1]
  def change
    change_column_default :card_orders, :send_delay, 2
  end
end
