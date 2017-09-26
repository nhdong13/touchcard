class RemoveNullCheckFromImageOnCardSides < ActiveRecord::Migration[4.2]
  def change
    change_column_null(:card_sides, :image, true)
  end
end
