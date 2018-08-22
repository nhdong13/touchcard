class RemoveCardSidesFromCardOrders < ActiveRecord::Migration[5.1]
  def up
    remove_column :card_orders, :card_side_front_id, :integer
    remove_column :card_orders, :card_side_back_id, :integer
  end

  def down
    add_column :card_orders, :card_side_front_id, :integer
    add_column :card_orders, :card_side_back_id, :integer
    CardSide.all.each do |card_side|
      if card_side.is_back
        card_side.card_order.card_side_back_id = card_side.id
      else
        card_side.card_order.card_side_front_id = card_side.id
      end
      card_side.save!
    end
  end
end
