require "slack_notify"

desc "Heroku scheduler task for sending cards"
task :daily_send_cards => :environment do
  puts "Sending Cards"
  cards_sent = Postcard.send_all

  puts "Notifying on #slack..."
  SlackNotify.cards_sent(cards_sent)
end

desc "Update Shop metadata and last_month New Customers"
task :update_shop_metadata => :environment do
  puts "Updating shop metadata for installed shops"
  Shop.where("uninstalled_at IS NULL").each do |shop|
    begin
      shop.sync_shopify_metadata
      shop.get_last_month
    rescue ActiveResource::UnauthorizedAccess
      logger.error "Unauthorized Access, Marking Shop as Uninstalled"
      shop.update_attributes(uninstalled_at: Time.now.midnight)
      next
    end
  end
end

desc "Slack Subscriptions Update"
task :slack_subscriptions_status => :environment do
  puts "Notifying subscription status on #slack..."
  quantity = Subscription.sum(:quantity)
  SlackNotify.subscriptions_status(quantity)
end

desc "Notify customers about postcard arival"
task :daily_send_card_arrival_emails => :environment do
  postcards = Postcard.ready_for_arrival_notification
  postcards.each do |postcard|
    # TODO: fix checking each customer for accepts_marketing.
    # When we add shop name column to db. We can make one query
    # and get everything needed
    if postcard.customer.accepts_marketing
      send_card_arrival_mail(postcard)
    end
  end
end


desc "Notify customers about coupon expiry"
task :hourly_send_coupon_expiration_emails => :environment do
  postcards = Postcard.where(sent: true, expiration_notification_sent: false)
  postcards.each do |postcard|
    discount_exp_at = postcard.discount_exp_at
    next if (discount_exp_at.nil? || postcard.discount_code.nil?)

    # Only attempt sending if coupon expires between 24 and 30 hours from now
    next if discount_exp_at > (Time.now + 30.hours)
    next if discount_exp_at < (Time.now + 24.hours)

    if postcard.customer.accepts_marketing
      send_coupon_expiration_email(postcard)
    end
  end
end

def send_card_arrival_mail(postcard)
  CustomerMailer.card_arrived_notification(postcard).deliver
  postcard.update_attributes(arrival_notification_sent: true)
end

def send_coupon_expiration_email(postcard)
  CustomerMailer.send_coupon_expiration_notification(postcard).deliver
  postcard.update_attributes(expiration_notification_sent: true)
end
