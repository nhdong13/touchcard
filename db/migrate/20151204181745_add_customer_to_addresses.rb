class AddCustomerToAddresses < ActiveRecord::Migration[4.2]
  def change
    change_table :addresses do |t|
      t.belongs_to :customer, index: true, foreign_key: true
    end
  end
end
