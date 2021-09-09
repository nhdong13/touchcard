require "slack_notify"

ActiveAdmin.register Shop do
  includes :subscriptions
  menu priority: 1 # so it's on the very left (default: 10)

  actions :index, :show

  member_action :adjust_credits, method: :get do
    @shop = Shop.find(params[:id])
  end

  member_action :change_credit, method: :put do
    new_credit = params[:credit].to_f
    shop = Shop.find(params[:id])
    SlackNotify.message("#{current_admin_user.email} changed #{shop.domain} credits " +
                            "from #{shop.credit} to #{new_credit}", true)
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

    # actions
    column :id do |shop|
      link_to shop.id, admin_shop_path(shop)
    end
    column :domain do |shop|
      shop.domain.split('.myshopify.com').first
    end
    column :name
    column :email
    column :owner
    column "Last Mo", :last_month
    column :credit do |shop|
      number_to_currency(shop.credit)
    end
    column "Sub Qty" do |shop|
      number_to_currency(shop.current_subscription.value) if shop.current_subscription
    end
    column "Last Login", :last_login_at
  end

  show do

    attributes_table do
      row :id
      row "Website Link" do |shop|
        link_to "https://#{shop.domain}", "https://#{shop.domain}", target: :_blank
      end
      row :name
      row :owner
      row :email
      row :customer_email
      row :last_month
      row :credit do |shop|
        status_tag(number_to_currency(shop.credit))
        link_to "edit", adjust_credits_admin_shop_path(shop)
      end
      row :sub_qty do |shop|
        status_tag(number_to_currency(shop.current_subscription ? shop.current_subscription.value : 0))
        link_to "edit", shop.current_subscription.present? ? change_subscription_credit_admin_subscription_path(shop.current_subscription, with_direct_path: true) : "#"
      end
      row :stripe_customer_id do |shop|
        link_to shop.stripe_customer_id, "https://dashboard.stripe.com/customers/#{shop.stripe_customer_id}", target: :_blank if shop.stripe_customer_id
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
          link_to(subscription.id, admin_subscription_path(subscription))
        end

        column :sub_qty do |subscription|
          number_to_currency(subscription.value)
        end
        column :plan_id
        column :current_period_start
        column :current_period_end
        column :created_at
        column :updated_at
        column :stripe_id do |subscription|
          link_to subscription.stripe_id, "https://dashboard.stripe.com/subscriptions/#{subscription.stripe_id}", target: :_blank if subscription.stripe_id
        end
      end
    end

    panel "Campaigns" do
      table_for shop.card_orders do
        column :id do |card_order|
          link_to card_order.id, admin_card_order_path(card_order)
        end
        column :campaign_name do |card_order|
          link_to card_order.campaign_name, admin_card_order_path(card_order)
        end
        column :campaign_type do |card_order|
          card_order.campaign_type&.gsub("_", "-")&.capitalize
        end
        column :enabled
        column :discount_pct do |card_order|
          card_order.discount_pct_to_str
        end
        column :discount_exp do |card_order|
          card_order.discount_exp_to_str
        end
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
