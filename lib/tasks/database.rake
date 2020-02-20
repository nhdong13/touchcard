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

# https://robots.thoughtbot.com/data-migrations-in-rails
namespace :cardsetup do
  desc "Takes data from customer's card_side and creates the relevant JSON in card_order"
  task :card_side_to_json => :environment do
    # raise "Expecting only positive discounts in DB" unless CardOrder.where("discount_pct < 0").count == 0

    card_orders = CardOrder.all
    puts card_orders
    puts "Updating #{card_orders.count} card_orders"
    card_orders.each do |card_order|
      ActiveRecord::Base.transaction do
        puts  "Shop: #{card_order.shop.name}"
        raise "Expecting empty target JSON, found background_url" if card_order.front_json["background_url"].present? || card_order.back_json["background_url"].present?
        raise "Expecting empty target JSON, found front discount coords" if card_order.front_json["discount_x"].present? || card_order.front_json["discount_y"].present?
        raise "Expecting empty target JSON, found back discount coords" if card_order.back_json["discount_x"].present? || card_order.back_json["discount_y"].present?

        front_x = card_order.card_side_front.discount_x
        front_y = card_order.card_side_front.discount_y
        back_x = card_order.card_side_back.discount_x
        back_y = card_order.card_side_back.discount_y

        raise "Expecting front source coordinates types to match" unless front_x.class == front_y.class
        raise "Expecting back source coordinates types to match" unless front_x.class == front_y.class

        card_order.front_json["background_url"] = card_order.card_side_front.image
        card_order.back_json["background_url"] = card_order.card_side_back.image

        x_scalar = 5.8  # manually tweaked to these
        y_scalar = 3.75

        # Make sure any out of range values are converted into something sensible
        card_order.discount_exp = card_order.discount_exp.clamp(1, 52) if card_order.discount_exp

        card_order.front_json["discount_x"] = (front_x.is_a? Numeric) ? front_x * x_scalar : nil
        card_order.front_json["discount_y"] = (front_y.is_a? Numeric) ? front_y * y_scalar : nil

        card_order.back_json["discount_x"] = (back_x.is_a? Numeric) ? back_x * x_scalar : nil
        card_order.back_json["discount_y"] = (back_y.is_a? Numeric) ? back_y * y_scalar : nil

        card_order.save!
        print "."
      end
    end
    puts "Completed"
  end
end


desc "Purge line items, old orders and orders for non-customers"
task :purge_older_data => :environment do
  raise "WARNING: Code not intended for production use" unless Rails.env.development?

  old_orders_without_postcards = Order.where(
      "id NOT IN (SELECT order_id FROM postcards WHERE order_id IS NOT null) AND created_at < ?",
      Time.now.midnight - 6.months)
  old_orders_without_postcards.delete_all

  orders_for_non_subscribers = Order.where("shop_id IN (SELECT id FROM shops WHERE stripe_customer_id IS null)")
  orders_for_non_subscribers.delete_all
  LineItem.delete_all
end



# namespace :price_rules do
#   desc "Convert positive discount values to negative for all CardOrders with positive discounts associated"
#   task :make_discounts_negative => :environment do
#     raise "Expecting only positive discounts in DB" unless CardOrder.where("discount_pct < 0").count == 0
#
#     card_orders = CardOrder.where("discount_pct > 0")
#     puts "Updating #{card_orders.count} card_orders"
#     ActiveRecord::Base.transaction do
#       card_orders.each do |card_order|
#         card_order.discount_pct = -card_order.discount_pct
#         card_order.save!
#         print "."
#       end
#     end
#     puts "Completed"
#   end
#
#   desc "Convert negative discount values to positive (undoing price rules upgrade)"
#   task :make_discounts_positive => :environment do
#     raise "Task may lose data if non-negative discounts exist" unless CardOrder.where("discount_pct > 0").count == 0
#
#     card_orders = CardOrder.where("discount_pct < 0")
#     puts "Updating #{card_orders.count} card_orders"
#     ActiveRecord::Base.transaction do
#       card_orders.each do |card_order|
#         card_order.discount_pct = (card_order.discount_pct).abs
#         card_order.save!
#         print "."
#       end
#     end
#     puts "Completed"
#   end
# end
