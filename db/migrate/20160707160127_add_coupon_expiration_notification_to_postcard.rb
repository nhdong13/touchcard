class AddCouponExpirationNotificationToPostcard < ActiveRecord::Migration
  def change
    add_column :postcards, :expiration_notification_sent, :boolean, default: false
    Postcard.update_all(expiration_notification_sent: true)
  end
end
