class AddShopMetadataJson < ActiveRecord::Migration
  def up
    add_column :shops, :metadata, :json, default: {}
    Shop.where("uninstalled_at IS NULL").each do |shop|
      begin
        shop.sync_shopify_metadata
      rescue ActiveResource::UnauthorizedAccess
        logger.error "Unauthorized Access, Marking Shop as Uninstalled"
        shop.update_attributes(uninstalled_at: Time.now.midnight)
        next
      end
    end
  end

  def down
    remove_column :shops, :metadata, :json, default: {}
  end
end
