class AddArrivialNotificationSentToPostcard < ActiveRecord::Migration
  def up
    add_column :postcards, :arrival_notification_sent, :boolean, null: false, default: false
    Postcard.all.each do |postcard|
      if postcard.estimated_arrival < 15.days.ago
        postcard.arrival_notification_sent = true
        postcard.save!
      end
    end
  end

  def down
    remove_column :postcards, :arrival_notification_sent
  end
end
