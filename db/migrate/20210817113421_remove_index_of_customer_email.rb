class RemoveIndexOfCustomerEmail < ActiveRecord::Migration[6.1]
  def change
    remove_index :customers, name: "index_customers_on_email"
  end
end
