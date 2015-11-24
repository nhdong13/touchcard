class AddAttributesToShop < ActiveRecord::Migration
  def change
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
end
