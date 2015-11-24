class CreateShops < ActiveRecord::Migration
  def change
    create_table :shops  do |t|
      t.string :domain, null: false
      t.string :token, null: false
      t.timestamps
    end

    add_index :shops, :domain, unique: true
  end
end
