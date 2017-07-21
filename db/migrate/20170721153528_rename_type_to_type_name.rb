class RenameTypeToTypeName < ActiveRecord::Migration
  def change
    rename_column :card_orders, :type, :type_name
  end
end
