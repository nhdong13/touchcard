class MoveShopToOrder < ActiveRecord::Migration
  def change
    remove_reference :customers, :shop, index: true, foreign_key: true
    add_reference :orders, :shop, index: true, foreign_key: true
  end
end
