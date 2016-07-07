class AddUninstalledAtAndLastLoggedInToShop < ActiveRecord::Migration
  def change
    add_column :shops, :uninstalled_at, :datetime
    add_column :shops, :last_login_at, :datetime
  end
end
