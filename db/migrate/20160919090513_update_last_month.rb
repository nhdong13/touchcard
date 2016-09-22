class UpdateLastMonth < ActiveRecord::Migration
  def up
    Shop.where("uninstalled_at IS NULL").each do |shop|
      begin
        shop.get_last_month
      rescue ActiveResource::UnauthorizedAccess
        logger.error "Unauthorized Access, Marking Shop as Uninstalled"
        shop.update_attributes(uninstalled_at: Time.now.midnight)
        next
      end
    end
  end
end
