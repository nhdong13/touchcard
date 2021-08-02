class ChangeDefaultColumnCardOrder < ActiveRecord::Migration[6.1]
  def change
    change_column_default(:card_orders, :send_continuously, from: false, to: true)
  end
end
