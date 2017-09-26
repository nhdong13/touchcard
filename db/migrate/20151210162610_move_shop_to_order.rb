class MoveShopToOrder < ActiveRecord::Migration[4.2]
  def change
    remove_reference :customers, :shop, index: true, foreign_key: true
    add_reference :orders, :shop, index: true, foreign_key: true
  end
end
