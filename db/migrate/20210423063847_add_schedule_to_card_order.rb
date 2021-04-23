class AddScheduleToCardOrder < ActiveRecord::Migration[5.2]
  def change
    rename_column :card_orders, :schedule, :send_date_start
    add_column :card_orders, :send_date_end, :datetime
  end
end
