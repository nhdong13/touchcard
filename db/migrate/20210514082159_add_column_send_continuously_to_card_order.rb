class AddColumnSendContinuouslyToCardOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :card_orders, :send_continuously, :boolean, default: false
  end
end
