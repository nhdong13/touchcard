class AddNameEmailPlanToShop < ActiveRecord::Migration
  def change
    add_column :shops, :name, :string
    add_column :shops, :email, :string
    add_column :shops, :customer_email, :string
    add_column :shops, :plan_name, :string
  end
end
