desc "Sync local version of shops information with latest from shopify"
task :sync_shopify_metadata => :environment do
  Shop.all.each do |shop|
    begin
      shop.new_sess
      shop.sync_shopify_metadata
    rescue
      next
    end
  end
end

namespace :price_rules do
  desc "Convert positive discount values to negative for all CardOrders with positive discounts associated"
  task :make_discounts_negative => :environment do
    raise "Expecting only positive discounts in DB" unless CardOrder.where("discount_pct < 0").count == 0

    card_orders = CardOrder.where("discount_pct > 0")
    puts "Updating #{card_orders.count} card_orders"
    ActiveRecord::Base.transaction do
      card_orders.each do |card_order|
        card_order.discount_pct = -card_order.discount_pct
        card_order.save!
        print "."
      end
    end
    puts "Completed"
  end

  desc "Convert negative discount values to positive (undoing price rules upgrade)"
  task :make_discounts_positive => :environment do
    raise "Task may lose data if non-negative discounts exist" unless CardOrder.where("discount_pct > 0").count == 0

    card_orders = CardOrder.where("discount_pct < 0")
    puts "Updating #{card_orders.count} card_orders"
    ActiveRecord::Base.transaction do
      card_orders.each do |card_order|
        card_order.discount_pct = (card_order.discount_pct).abs
        card_order.save!
        print "."
      end
    end
    puts "Completed"
  end
end
