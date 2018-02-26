class UpdatePostcardDiscountDetails < ActiveRecord::Migration[4.2]
  def up
    postcards = Postcard.where(sent: true)
    postcards.each do |p|
      # CardOrder.discount? has been replaced with CardOrder.has_discounts?
      # We have not modified this migration accordingly
      next if not p.card_order.discount?
      exp_at = p.estimated_arrival + p.card_order.discount_exp.weeks
      p.update_attributes(discount_pct: p.card_order.discount_pct,
                          discount_exp_at: exp_at)
    end
  end

  def down
  end
end
