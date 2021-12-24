class AddReplenishDateToCardOrders < ActiveRecord::Migration[6.1]
  def change
    add_column :card_orders, :replenish_date, :date
    CardOrder.find_each do |cp|
      cp.replenish_date = cp.send_date_start
      cp.save
    end
  end
end
