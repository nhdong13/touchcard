class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.text :address1
      t.text :address2
      t.text :city
      t.text :company
      t.text :country
      t.string :country_code
      t.string :first_name
      t.string :last_name
      t.float :latitude
      t.float :longitude
      t.text :phone
      t.text :province
      t.text :zip
      t.string :name
      t.string :text
      t.string :province_code
      t.boolean :default
      t.integer :shopify_id, null: false, index: { unique: true }, limit: 8
      t.timestamps null: false
    end
  end
end
