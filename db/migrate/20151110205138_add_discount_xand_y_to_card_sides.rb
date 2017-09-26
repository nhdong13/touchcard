class AddDiscountXandYToCardSides < ActiveRecord::Migration[4.2]
  def change
    add_column :card_sides, :discount_y, :integer
    add_column :card_sides, :discount_x, :integer
  end
end
