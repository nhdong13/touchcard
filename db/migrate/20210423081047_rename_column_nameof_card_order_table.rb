class RenameColumnNameofCardOrderTable < ActiveRecord::Migration[5.2]
  def change
    rename_column :card_orders, :name, :campaign_name
  end
end
