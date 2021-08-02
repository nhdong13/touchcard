class AddBudgetUpdateToPostCard < ActiveRecord::Migration[5.2]
  def change
    add_column :card_orders, :budget_update, :integer, default: 0
    change_column :card_orders, :budget, :integer, default: 0
  end
end
