require "slack_notify"
require 'byebug'

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
    if postcard.customer.accepts_marketing
      send_card_arrival_mail(postcard)
      set_customer_as_notified(postcard)
    end
  end
end

def send_card_arrival_mail(postcard)
  CustomerMailer.card_arrived_notification(postcard).deliver
end

def set_customer_as_notified(postcard)
  postcard.update_attributes(arrival_notification_sent: true)
end

