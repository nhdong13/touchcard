ActiveAdmin.register Subscription do

  index do
    column :id
    column :quantity
    column :current_period_start
    column :current_period_end
    actions
  end

  show do
    attributes_table :id, :quantity, :current_period_start, :current_period_end
  end

end
