class AddDiscountPctAndDiscountExpToPostcard < ActiveRecord::Migration[4.2]
  def up
    add_column :postcards, :discount_pct, :integer
    add_column :postcards, :discount_exp_at, :datetime
  end

  def down
    remove_column :postcards, :discount_pct, :integer
    remove_column :postcards, :discount_exp_at, :datetime
  end
end
