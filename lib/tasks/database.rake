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

namespace :convert_discount_values do
  desc "Convert positive discount values to negative for all Postcards scheduled for sending after migration to price rules"
  task :for_postcards => :environment do
    postcards_for_conversion = Postcards.joins(:shops)
      .where("paid = TRUE AND sent = FALSE AND send_date >= ?
            AND shops.approval_state != ?", Time.now, "denied")

    postcards_for_conversion.each do |postcard|
      if postcard.discount_pct > 0
        postcard.discount_pct = -postcard.discount_pct
        postcard.save!
      end
    end
  end

  desc "Convert positive discount values to negative for all CardOrders created before migration to price rules"
  task :for_card_orders => :environment do
    CardOrder.each do |card_order|
      if card_order.discount_pct > 0
        card_order.discount_pct = -card_order.discount_pct
        card_order.save!
      end
    end
  end
end
