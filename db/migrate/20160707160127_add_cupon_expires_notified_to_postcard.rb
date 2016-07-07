class AddCuponExpiresNotifiedToPostcard < ActiveRecord::Migration
  def change
    add_column :postcards, :coupon_expires_notified, :boolean, default: false
    Postcard.update_all(coupon_expires_notified: true)
  end
end
