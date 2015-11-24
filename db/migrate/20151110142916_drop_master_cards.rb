class DropMasterCards < ActiveRecord::Migration
  def change
    drop_table :master_cards
  end
end
