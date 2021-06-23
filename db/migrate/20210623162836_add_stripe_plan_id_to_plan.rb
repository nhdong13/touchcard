class AddStripePlanIdToPlan < ActiveRecord::Migration[6.1]
  def change
    add_column :plans, :stripe_plan_id, :string
  end
end
