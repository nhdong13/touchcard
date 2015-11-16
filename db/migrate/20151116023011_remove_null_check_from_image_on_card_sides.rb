class RemoveNullCheckFromImageOnCardSides < ActiveRecord::Migration
  def change
    change_column_null(:card_sides, :image, true)
  end
end
