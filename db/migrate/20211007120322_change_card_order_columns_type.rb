class ChangeCardOrderColumnsType < ActiveRecord::Migration[6.1]
  def change
    change_column :card_orders, :send_date_start, :date
    change_column :card_orders, :send_date_end, :date
  end
end
