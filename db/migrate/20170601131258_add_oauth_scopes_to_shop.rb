class AddOauthScopesToShop < ActiveRecord::Migration[4.2]
  def change
    add_column :shops, :oauth_scopes, :text
  end
end
