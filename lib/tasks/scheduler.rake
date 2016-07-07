require "slack_notify"

desc "Heroku scheduler task for sending cards"
task :daily_send_cards => :environment do
  puts "Sending Cards"
  cards_sent = Postcard.send_all

  puts "Notifying on #slack..."
  SlackNotify.cards_sent(cards_sent)
end

desc "Top up credit on all shops with a billing date of today"
task :daily_credit_update => :environment do
  puts "Topping up shop credits"
  Shop.top_up_all
end

desc "Notify customers about postcard arival"
task :daily_cards_arrived_notify => :environment do
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
task :coupon_about_to_expire_notify => :environment do
  postcards = Postcard.where(sent: true, coupon_expires_notified: false)
  postcards.each do |postcard|
    discount_exp = postcard.card_order.discount_exp
    next if (discount_exp.nil? && postcard.discount_code.nil?)

    expires = (postcard.estimated_arrival + discount_exp.weeks)

    # Safe buffer find ones that expires in 30 hours or less
    next unless (Time.now + 30.hours) > expires

    send_coupon_expires_mail(postcard)
  end
end

def send_card_arrival_mail(postcard)
  CustomerMailer.card_arrived_notification(postcard).deliver
  postcard.update_attributes(arrival_notification_sent: true)
end

def send_coupon_expires_mail(postcard)
  CustomerMailer.send_coupon_expires(postcard).deliver
  postcard.update_attributes(coupon_expires_notified: true)
end
