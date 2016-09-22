class UpdateLastMonth < ActiveRecord::Migration
  def up
    Shop.where("uninstalled_at IS NULL").each do |shop|
      begin
        shop.get_last_month
      rescue ActiveResource::UnauthorizedAccess, ActiveResource::ClientError => e
        logger.error "#{e.message}"
        logger.error "Adding Uninstalled Date"
        shop.update_attributes(uninstalled_at: Time.new(2016))
        next
      end
    end
  end
end
