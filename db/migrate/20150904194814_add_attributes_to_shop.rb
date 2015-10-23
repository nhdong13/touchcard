class AddAttributesToShop < ActiveRecord::Migration
  def up
    add_column :shops, :shopify_id,     :bigint
    add_column :shops, :credit,         :int, default: 0
    add_column :shops, :webhook_id,     :bigint
    add_column :shops, :uninstall_id,   :bigint
    add_column :shops, :charge_id,      :bigint
    add_column :shops, :charge_amount,  :int, default: 0
    add_column :shops, :charge_date,    :datetime
    add_column :shops, :customer_pct,   :int, default: 100
    add_column :shops, :last_month,     :int
    add_column :shops, :send_next,      :boolean, null: false, default: true
    add_column :shops, :last_login,     :datetime
  end

  def down
    remove_column :shops, :shopify_id
    remove_column :shops, :credit
    remove_column :shops, :webhook_id
    remove_column :shops, :uninstall_id
    remove_column :shops, :charge_id
    remove_column :shops, :charge_amount
    remove_column :shops, :charge_date
    remove_column :shops, :customer_pct
    remove_column :shops, :last_month
    remove_column :shops, :send_next
    remove_column :shops, :last_login
  end
end
