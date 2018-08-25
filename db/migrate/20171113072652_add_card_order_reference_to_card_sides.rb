class AddCardOrderReferenceToCardSides < ActiveRecord::Migration[5.1]
  def up
    add_reference :card_sides, :card_order, foreign_key: true
    CardOrder.all.each do |card_order|
      [card_order.card_side_front_id, card_order.card_side_back_id].map do |card_side_id|
        card_side = CardSide.find(card_side_id)
        card_side.card_order_id = card_order.id
        card_side.save!
      end

    end
  end

  def down
    remove_reference :card_sides, :card_order, foreign_key: true
  end
end
