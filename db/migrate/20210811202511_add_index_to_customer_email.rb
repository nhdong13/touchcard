class AddIndexToCustomerEmail < ActiveRecord::Migration[6.1]
  def change
    add_index :customers, :email
  end
end
