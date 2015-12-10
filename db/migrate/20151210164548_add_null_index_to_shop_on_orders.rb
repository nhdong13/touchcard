class AddNullIndexToShopOnOrders < ActiveRecord::Migration
  def change
    change_column :orders, :shop_id, :integer, null: false
  end
end
