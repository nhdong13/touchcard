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

    actions
    column :quantity do |subscription|
          link_to subscription.quantity, new_quantity_change_admin_subscription_path(subscription)
    end
    column :id
    column :current_period_start
    column :current_period_end
  end

  show do
    attributes_table do
      row :id
      row :quantity do |subscription|
        link_to subscription.quantity, new_quantity_change_admin_subscription_path(subscription)
      end
      row :current_period_start
      row :current_period_end
      row :created_at
      row :updated_at
      row :stripe_id do |subscription|
        link_to subscription.stripe_id, "https://dashboard.stripe.com/subscriptions/#{subscription.stripe_id}"
      end
    end
  end

end
