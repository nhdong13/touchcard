class UpdatePostcardDiscountDetails < ActiveRecord::Migration
  def up
    postcards = Postcard.where(sent: true)
    postcards.each do |p|
      next if not p.card_order.discount?
      exp_at = p.estimated_arrival + p.card_order.discount_exp.weeks
      p.update_attributes(discount_pct: p.card_order.discount_pct,
                          discount_exp_at: exp_at)
    end
  end

  def down
  end
end
