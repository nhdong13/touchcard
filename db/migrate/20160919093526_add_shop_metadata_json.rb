class AddShopMetadataJson < ActiveRecord::Migration
  def up
    add_column :shops, :metadata, :json, default: {}
    Shop.all.each do |shop|
      shop.sync_shopify_metadata
    end
  end

  def down
    remove_column :shops, :metadata, :json, default: {}
  end
end
