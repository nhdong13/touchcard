class CreateMasterCards < ActiveRecord::Migration
  def change
    create_table :master_cards do |t|
      t.belongs_to :shop
      t.timestamps null: false
    end
  end
end
