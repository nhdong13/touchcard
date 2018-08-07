class AddCardOrderReferenceToCardSides < ActiveRecord::Migration[5.1]
  def change
    add_reference :card_sides, :card_order, foreign_key: true
  end
end
