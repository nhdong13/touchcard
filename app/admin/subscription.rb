ActiveAdmin.register Subscription do
  actions :index, :show

  member_action :change_quantity, method: :get do

  end

  index do
    column :id
    column :quantity
    column :current_period_start
    column :current_period_end
    actions do |subscription|
      link_to "Change Quantity", change_quantity_admin_subscription_path(subscription)
    end
  end

  show do
    attributes_table :id, :quantity, :current_period_start, :current_period_end
  end

end
