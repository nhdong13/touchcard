class RenameCouponToDiscount < ActiveRecord::Migration
  def change
    rename_column :card_templates, :coupon_pct, :discount_pct
    rename_column :card_templates, :coupon_loc, :discount_loc
    rename_column :card_templates, :coupon_exp, :discount_exp
    rename_column :postcards, :coupon, :discount_code
  end
end
