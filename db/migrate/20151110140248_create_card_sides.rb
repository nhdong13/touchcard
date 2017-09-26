class CreateCardSides < ActiveRecord::Migration[4.2]
  def change
    create_table :card_sides do |t|
      t.text :image, null: false
      t.text :preview
      t.boolean :is_back, null: false

      t.timestamps null: false
    end
  end
end
