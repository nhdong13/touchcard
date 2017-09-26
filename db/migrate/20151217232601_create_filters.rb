class CreateFilters < ActiveRecord::Migration[4.2]
  def change
    create_table :filters do |t|
      t.belongs_to :card_order, index: true, foreign_key: true
      t.text :filter_data, null: false

      t.timestamps null: false
    end
  end
end
