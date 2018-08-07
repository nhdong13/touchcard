class RemoveCardSidesFromCardOrders < ActiveRecord::Migration[5.1]
  def change
    remove_column :card_orders, :card_side_front_id, :integer
    remove_column :card_orders, :card_side_back_id, :integer
  end
end
