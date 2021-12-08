require "slack_notify"

ActiveAdmin.register Subscription do
  actions :index, :show
  menu priority: 3 # so it's on the very left (default: 10)

  member_action :change_subscription_quantity, method: :get do
    @subscription = Subscription.find(params[:id])
  end

  member_action :change_quantity, method: :put do
    new_quantity = params[:subscription][:quantity].to_i
    subscription = Subscription.find(params[:id])
    SlackNotify.message("#{current_admin_user.email} changed #{subscription.shop.domain} subscription " +
                            "from #{subscription.quantity} to #{new_quantity}", true)
    subscription.change_quantity(new_quantity)
    redirect_path = params[:with_direct_path] == "true" ? admin_shop_path(subscription.shop) : admin_subscription_path(subscription)
    redirect_to redirect_path
  end

  member_action :change_subscription_credit, method: :get do
    @subscription = Subscription.find(params[:id])
  end

  member_action :change_credit, method: :put do
    new_credit = params[:value].to_f
    subscription = Subscription.find(params[:id])
    SlackNotify.message("#{current_admin_user.email} changed #{subscription.shop.domain} subscription " +
                            "from #{subscription.value} to #{new_credit}", true)
    subscription.change_quantity_by_credit(new_credit)
    redirect_path = params[:with_direct_path] == "true" ? admin_shop_path(subscription.shop) : admin_subscription_path(subscription)
    redirect_to redirect_path
  end

  filter :shop , as: :select, collection: ->{Shop.select(:domain, :id).order(:domain)}
  filter :plan
  filter :quantity
  filter :current_period_start
  filter :current_period_end
  filter :created_at
  filter :updated_at
  filter :stripe_id

  includes :shop

  index do
    # actions
    column :id do |subscription|
      link_to subscription.id, admin_subscription_path(subscription)
    end
    column :shop, :sortable => 'shops.name' do |subscription|
      subscription.shop
    end
    column 'Sub Qty', sortable: :value do |subscription|
      number_to_currency(subscription.value)
    end
    column :current_period_start
    column :current_period_end
    column :created_at
  end

  show do
    attributes_table do
      row :shop do |subscription|
        subscription.shop
      end
      row :id
      row :sub_qty do |subscription|
        status_tag(number_to_currency(subscription.value))
        link_to "edit", change_subscription_quantity_admin_subscription_path(subscription)
      end
      # row :quantity do |subscription|
      #   status_tag(subscription.quantity)
      #   link_to "edit", change_subscription_quantity_admin_subscription_path(subscription)
      # end
      row :current_period_start
      row :current_period_end
      row :created_at
      row :updated_at
      row :stripe_id do |subscription|
        link_to subscription.stripe_id, "https://dashboard.stripe.com/subscriptions/#{subscription.stripe_id}", target: :_blank
      end
    end
  end
end
