class CreateCards < ActiveRecord::Migration
  def self.up
    create_table :cards do |t|
      t.belongs_to  :shop
      t.string      :template
      t.string      :image_front
      t.string      :image_back
      t.string      :text_front
      t.string      :text_back

      t.timestamps null: false
    end
  end

  def self.down
    drop_table :cards
  end
end
