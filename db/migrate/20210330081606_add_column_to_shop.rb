class AddColumnToShop < ActiveRecord::Migration[5.2]
  def change
    add_column :shops, :shopify_history_data_imported, :datetime
    add_column :shops, :shopify_history_data_imported_duration, :integer
  end
end
