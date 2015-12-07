class AddCustomerToAddresses < ActiveRecord::Migration
  def change
    change_table :addresses do |t|
      t.belongs_to :customer, index: true, foreign_key: true
    end
  end
end
