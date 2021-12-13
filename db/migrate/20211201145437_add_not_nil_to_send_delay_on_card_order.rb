class AddNotNilToSendDelayOnCardOrder < ActiveRecord::Migration[6.1]
  def change
    change_column :card_orders, :send_delay, :integer, default: 0, null: false
  end
end
