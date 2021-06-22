class ChangeCreditToBudgetUsed < ActiveRecord::Migration[6.1]
  def change
    rename_column :card_orders, :credits, :budget_used
  end
end
