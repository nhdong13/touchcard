class UpdateLastMonth < ActiveRecord::Migration[4.2]
  def up
    Shop.where("uninstalled_at IS NULL").each do |shop|
      begin
        shop.update_last_month
      rescue ActiveResource::UnauthorizedAccess, ActiveResource::ClientError => e
        logger.error "#{e.message}"
        logger.error "Adding Uninstalled Date"
        shop.update_attributes(uninstalled_at: Time.new(2016))
        next
      end
    end
  end
end
