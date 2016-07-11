desc "Sanitize postcard links, pass shop id as first argument"
task :sanitize_postcard_links => :environment do
  # Note: This removes postcard links for non-coupon orders.
  # There may be non-Touchcard coupons 'incorrectly' linked to a
  # postcard, these need to be removed manually.
  shop_id = ARGV[1]
  orders = Order.where("shop_id = #{shop_id} and postcard_id is not null")
  orders.each do |order|
    if order.discount_codes.blank?
      order.update_attributes(postcard_id: nil)
    end
  end
end
