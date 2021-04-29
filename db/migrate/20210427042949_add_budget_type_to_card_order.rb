class AddBudgetTypeToCardOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :card_orders, :budget_type, :integer, default: 0
  end
end
