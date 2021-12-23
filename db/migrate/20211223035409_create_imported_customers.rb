class CreateImportedCustomers < ActiveRecord::Migration[6.1]
  def change
    create_table :imported_customers do |t|
      t.string :name
      t.string :address1
      t.string :address2
      t.string :city
      t.string :province_code
      t.string :country_code
      t.string :zip
      t.belongs_to :card_order, index: true, foreign_key: true
      t.timestamps
    end

    add_column :card_orders, :imported_customers_url, :string
    add_reference :postcards, :imported_customer, index: true, foreign_key: true
  end
end