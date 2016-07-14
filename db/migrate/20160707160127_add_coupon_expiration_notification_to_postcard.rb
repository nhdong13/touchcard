class AddCouponExpirationNotificationToPostcard < ActiveRecord::Migration
  def up
    add_column :postcards, :expiration_notification_sent, :boolean, default: false

    Postcard.update_all(expiration_notification_sent: true)
    postcards = Postcard.where(sent: true)
    postcards.each do |postcard|
      discount_exp = postcard.card_order.discount_exp
      next if (discount_exp.nil? || postcard.discount_code.nil?)

      expires = (postcard.estimated_arrival + discount_exp.weeks)

      # Safe buffer find ones that expires in 30 hours or less
      next unless (Time.now + 24.hours) < expires

      postcard.update_attributes(expiration_notification_sent: false)
    end
  end

  def down
    remove_column :postcards, :expiration_notification_sent, :boolean, default: false
  end
end
