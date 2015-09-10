class AddAttributesToShop < ActiveRecord::Migration
  def up
    add_column :shops, :shopify_id, :bigint
    add_column :shops, :credit, :int
    add_column :shops, :enabled, :boolean
    add_column :shops, :international, :boolean
    add_column :shops, :send_delay, :int
    add_column :shops, :webhook_id, :bigint
    add_column :shops, :uninstall_id, :bigint
  end

  def down
    remove_column :shops, :shopify_id
    remove_column :shops, :credit
    remove_column :shops, :enabled
    remove_column :shops, :international
    remove_column :shops, :send_delay
    remove_column :shops, :webhook_id
    remove_column :shops, :uninstall_id
  end
end
