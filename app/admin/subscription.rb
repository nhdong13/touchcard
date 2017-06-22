ActiveAdmin.register Subscription do
  actions :index, :show

  member_action :new_quantity_change, method: :get do
    @subscription = Subscription.find(params[:id])
  end

  member_action :change_quantity, method: :put do
    new_quantity = params[:subscription][:quantity].to_i
    subscription = Subscription.find(params[:id])

    subscription.change_quantity(new_quantity)
    redirect_to admin_subscription_path(subscription)
  end

  index do
    column :id
    column :quantity
    column :current_period_start
    column :current_period_end
    actions do |subscription|
      link_to "Change Quantity", new_quantity_change_admin_subscription_path(subscription)
    end
  end

  show do
    attributes_table :id, :quantity, :current_period_start, :current_period_end
  end

end
