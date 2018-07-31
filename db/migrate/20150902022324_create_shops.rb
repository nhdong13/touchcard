class CreateShops < ActiveRecord::Migration[4.2]
  def change
    create_table :shops  do |t|
      t.string :domain, null: false
      t.string :token, null: false
      t.timestamps
    end

    add_index :shops, :domain, unique: true
  end
end
