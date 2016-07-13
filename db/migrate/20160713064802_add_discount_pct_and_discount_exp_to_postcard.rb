class AddDiscountPctAndDiscountExpToPostcard < ActiveRecord::Migration
  def change
    add_column :postcards, :discount_pct, :integer
    add_column :postcards, :discount_exp, :integer

    card_orders = CardOrder.all
    card_orders.each do |co|
      if co.postcards.any?
       co.postcards.update_all(discount_pct: co.discount_pct,
                               discount_exp: co.discount_exp)
      end
    end
  end
end
