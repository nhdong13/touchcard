desc "Heroku scheduler task for sending cards"
task :daily_send_cards => :environment do
  puts "Sending Cards"
  Card.send_all
end

desc "Top up credit on all shops with a billing date of today"
task :daily_credit_update => :environment do
  puts "Topping up shop credits"
  Shop.top_up_all
end
