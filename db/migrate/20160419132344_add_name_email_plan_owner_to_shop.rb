class AddNameEmailPlanOwnerToShop < ActiveRecord::Migration
  def change
    add_column :shops, :name, :string
    add_column :shops, :email, :string
    add_column :shops, :customer_email, :string
    add_column :shops, :plan_name, :string
    add_column :shops, :owner, :string
  end
end
