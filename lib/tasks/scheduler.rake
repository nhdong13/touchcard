desc "Heroku scheduler task for sending cards"
task :daily_send_cards => :environment do
  puts "Sending Cards"
  Postcard.send_all
end

desc "Poll customers for second purchase"
task :daily_revenue_poll => :environment do
  puts "Calculating revenue"
  CardTemplate.update_all_revenues
end

desc "Top up credit on all shops with a billing date of today"
task :daily_credit_update => :environment do
  puts "Topping up shop credits"
  Shop.top_up_all
end
