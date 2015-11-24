class AddStripeToShop < ActiveRecord::Migration
  def change
    add_column :shops, :stripe_customer_id, :string, index:true
  end
end
