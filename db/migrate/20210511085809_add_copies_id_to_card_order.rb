class AddCopiesIdToCardOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :card_orders, :card_order_parent_id, :integer
  end
end
