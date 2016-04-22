class AddShopifyDatesToShop < ActiveRecord::Migration
  def change
    add_column :shops, :shopify_created_at, :datetime
    add_column :shops, :shopify_updated_at, :datetime
  end
end
