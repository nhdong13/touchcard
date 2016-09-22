class AddShopMetadataJson < ActiveRecord::Migration
  def up
    add_column :shops, :metadata, :json, default: {}
    Shop.reset_column_information
    Shop.where("uninstalled_at IS NULL").each do |shop|
      begin
        shop.sync_shopify_metadata
      rescue ActiveResource::UnauthorizedAccess, ActiveResource::ClientError => e
        logger.error "#{e.message}"
        logger.error "Adding Uninstalled Date"
        shop.update_attributes(uninstalled_at: Time.new(2016))
        next
      end
    end
  end

  def down
    remove_column :shops, :metadata, :json, default: {}
  end
end
