class AddDiscountPctAndDiscountExpToPostcard < ActiveRecord::Migration
  def up
    add_column :postcards, :discount_pct, :integer
    add_column :postcards, :discount_exp_at, :datetime

    postcards = Postcard.where(sent: true)
    postcards.each do |p|
      exp_at = p.estimated_arrival + p.card_order.discount_exp.weeks
      p.update_attributs(discount_pct: co.discount_pct,
                         discount_exp_at: exp_at)
    end
  end

  def down
    remove_column :postcards, :discount_pct, :integer
    remove_column :postcards, :discount_exp_at, :datetime
  end
end
