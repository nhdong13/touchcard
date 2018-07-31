class AddShopToCustomer < ActiveRecord::Migration[4.2]
  def change
    add_reference :customers, :shop, index: true, foreign_key: true
  end
end
