class AddFrontBackDataToCardOrders < ActiveRecord::Migration[5.1]
  def up
    add_column :card_orders, :front_json, :json, default: {}
    add_column :card_orders, :back_json, :json, default: {}

    CardOrder.all.each do |card_order|
      card_order.front_json, card_order.back_json = [
        card_order.card_side_front,
        card_order.card_side_back
      ].map do |card_side|
        { version: 0,
          background_url: card_side.image,
          discount_x: card_side.discount_x,
          discount_y: card_side.discount_y
        }
      end
      card_order.save!
    end
  end


  def down
    remove_column :card_orders, :front_json, :json
    remove_column :card_orders, :back_json, :json
  end
end
