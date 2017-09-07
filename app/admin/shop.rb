require "slack_notify"

ActiveAdmin.register Shop do
  includes :subscriptions
  menu priority: 1 # so it's on the very left (default: 10)

  actions :index, :show

  member_action :adjust_credits, method: :get do
    @shop = Shop.find(params[:id])
  end

  member_action :change_credit, method: :put do
    new_credit = params[:shop][:credit].to_i
    shop = Shop.find(params[:id])
    SlackNotify.message("#{current_admin_user.email} changed #{shop.domain} credits " +
                            "from #{shop.credit} to #{new_credit}")
    shop.credit = new_credit
    shop.save!
    redirect_to admin_shop_path(shop)
  end

  # More on filtering
  # https://hashrocket.com/blog/posts/customize-activeadmin-index-filters

  filter :domain, label: "Shopify URL"
  filter :stripe_customer_id, label: "Stripe Customer ID"
  filter :name, label: "Shop Name"
  filter :email
  filter :customer_email
  filter :owner

  index do
    div class: 'top_pagination' do
      paginated_collection(collection, download_links: false)
    end

    actions
    column :id
    column :domain do |shop|
      link_to shop.domain, "https://#{shop.domain}"
    end
    column :name
    column :email
    column :owner
    column :last_month
    column :credit
    column "Subscription Quantity" do |shop|
      shop.current_subscription.quantity if shop.current_subscription
    end
    column :last_login_at
  end

  show do

    attributes_table do
      row :id
      row :domain do |shop|
        link_to shop.domain, "https://#{shop.domain}"
      end
      row :name
      row :owner
      row :email
      row :customer_email
      row :last_month
      row :credit do |shop|
        status_tag("#{shop.credit}")
        link_to "edit", adjust_credits_admin_shop_path(shop)
      end
      row :stripe_customer_id do |shop|
        link_to shop.stripe_customer_id, "https://dashboard.stripe.com/customers/#{shop.stripe_customer_id}" if shop.stripe_customer_id
      end
      row :approval_state
      row :plan_name
      row :last_login_at
      row :created_at
      row :updated_at
      row :uninstalled_at
      row "Postcards" do
        link_to "List of Postcards",
                controller: "postcards",
                action: "index",
                'q[card_order_shop_id_eq]' => "#{shop.id}".html_safe
      end
      row "Orders" do
        link_to "List of Orders",
                controller: "orders",
                action: "index",
                'q[shop_id_eq]' => "#{shop.id}".html_safe
      end


    end

    panel "Subscription Data" do
      table_for shop.subscriptions do
        column :id do |subscription|
          link_to(subscription.id, :admin_subscription)
        end

        column :quantity
        column :plan_id
        column :current_period_start
        column :current_period_end
        column :created_at
        column :updated_at
        column :stripe_id do |subscription|
          link_to subscription.stripe_id, "https://dashboard.stripe.com/subscriptions/#{subscription.stripe_id}"
        end
      end
    end

    panel "Card Orders" do
      table_for shop.card_orders do
        column :id do |card_order|
          link_to(card_order.id, :admin_card_order)
        end
        column :type
        column :enabled
        column :send_delay
        column :discount_pct
        column :discount_exp
        column :card_side_front_id
        column :card_side_back_id
      end
    end
  end

  # form do |f|
  #   f.inputs "Change Shop Credit" do
  #     f.input :credit
  #   end
  #   f.actions
  # end

end
