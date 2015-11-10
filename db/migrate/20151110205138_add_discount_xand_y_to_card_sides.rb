class AddDiscountXandYToCardSides < ActiveRecord::Migration
  def change
    add_column :card_sides, :discount_y, :integer
    add_column :card_sides, :discount_x, :integer
  end
end
