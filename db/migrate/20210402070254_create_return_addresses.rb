class CreateReturnAddresses < ActiveRecord::Migration[5.2]
  def change
    create_table :return_addresses do |t|
      t.string :name
      t.string :address_line1
      t.string :address_line2
      t.string :city
      t.string :state
      t.string :zip
      t.string :country_code
      t.integer :card_order_id

      t.timestamps
    end
  end
end
