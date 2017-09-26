class DropRevenueFromCardOrder < ActiveRecord::Migration[4.2]
  def change
    remove_column :card_orders, :revenue
  end
end
