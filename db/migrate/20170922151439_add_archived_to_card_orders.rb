class AddArchivedToCardOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :card_orders, :archived, :boolean, default: false
  end
end
