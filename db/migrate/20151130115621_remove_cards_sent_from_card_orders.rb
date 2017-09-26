class RemoveCardsSentFromCardOrders < ActiveRecord::Migration[4.2]
  def change
    remove_column :card_orders, :cards_sent
  end
end
