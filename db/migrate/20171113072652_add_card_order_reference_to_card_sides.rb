class AddCardOrderReferenceToCardSides < ActiveRecord::Migration[5.1]
  def up
    add_reference :card_sides, :card_order, foreign_key: true
    CardOrder.all.each do |card_order|
      card_order.card_side_front.card_order_id = card_order.id
      card_order.card_side_back.card_order_id = card_order.id
      # Make sure there's no out of range errors
      card_order.discount_exp = card_order.discount_exp.clamp(1, 52) if card_order.discount_exp
      card_order.save!
    end
  end

  def down
    remove_reference :card_sides, :card_order, foreign_key: true
  end
end
