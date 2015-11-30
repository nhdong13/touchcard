class RemoveCardsSentFromCardOrders < ActiveRecord::Migration
  def change
    remove_column :card_orders, :cards_sent
  end
end
