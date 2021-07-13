class ChangeTokenToCreditShop < ActiveRecord::Migration[6.1]
  def up
    change_column :shops, :credit, :float
    change_column :card_orders, :budget, :float
    change_column :card_orders, :budget_used, :float
    change_column :card_orders, :budget_update, :float
  end

  def down
    change_column :shops, :credit, :integer
    change_column :card_orders, :budget, :integer
    change_column :card_orders, :budget_used, :integer
    change_column :card_orders, :budget_update, :integer
  end
end
