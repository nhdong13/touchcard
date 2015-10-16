class AddOrderIdToCards < ActiveRecord::Migration
  def up
    add_column :cards, :order_id, :bigint
  end

  def down
    remove_column :cards, :order_id
  end
end
