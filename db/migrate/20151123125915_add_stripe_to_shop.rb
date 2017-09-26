class AddStripeToShop < ActiveRecord::Migration[4.2]
  def change
    add_column :shops, :stripe_customer_id, :string, index:true
  end
end
