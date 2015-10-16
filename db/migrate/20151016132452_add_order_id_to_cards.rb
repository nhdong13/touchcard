class AddOrderIdToCards < ActiveRecord::Migration
  def up
    add_column :cards, :order_id, :bigint
    change_column :cards, :postcard_id, :string
  end

  def down
    remove_column :cards, :order_id
    change_column :cards, :postcard_id, :bigint
  end
end
