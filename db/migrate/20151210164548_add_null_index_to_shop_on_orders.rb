class AddNullIndexToShopOnOrders < ActiveRecord::Migration[4.2]
  def change
    change_column :orders, :shop_id, :integer, null: false
  end
end
