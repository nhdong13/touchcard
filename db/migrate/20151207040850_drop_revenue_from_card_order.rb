class DropRevenueFromCardOrder < ActiveRecord::Migration
  def change
    remove_column :card_orders, :revenue
  end
end
