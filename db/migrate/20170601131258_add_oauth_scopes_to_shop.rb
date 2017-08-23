class AddOauthScopesToShop < ActiveRecord::Migration
  def change
    add_column :shops, :oauth_scopes, :text
  end
end
