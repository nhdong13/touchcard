class RefactorCardSideOutOfCardTemplate < ActiveRecord::Migration
  def change
    change_table :card_templates do |t|
      t.remove :style
      t.remove :image_front
      t.remove :image_back
      t.remove :logo
      t.remove :title_front
      t.remove :text_front
      t.remove :preview_front
      t.remove :preview_back
      t.remove :discount_loc
      t.remove :transaction_id

      t.integer :card_side_front_id, null: false
      t.integer :card_side_back_id, null: false
    end
  end
end
