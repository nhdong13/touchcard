ActiveAdmin.register Shop do
  includes :subscriptions
  includes :card_orders

  remove_filter :postcards
  remove_filter :orders
  remove_filter :token
  remove_filter :charges
  remove_filter :charge_amount
  remove_filter :charge_date
  remove_filter :plan_name
  remove_filter :shopify_created_at
  remove_filter :shopify_updated_at

  index do
    div class: 'top_pagination' do
      paginated_collection(collection, download_links: false)
    end

    column :id
    column :domain
    column :created_at
    column :updated_at
    column :uninstalled_at
    column :last_login_at
    column :email
    column :customer_email
    column :plan_name
    column :owner
    column :name
    column :approval_state
    column :last_month
    column :credit
    column "Subscription Quantity" do |shop|
      shop.current_subscription.quantity if shop.current_subscription
    end
    actions
  end

  show do
    attributes_table :domain, :email, :owner, :name

    panel "Subscription Data" do
      table_for shop.subscriptions do
        column :id
        column :quantity
        column :plan_id
        column :shop_id
        column :current_period_start
        column :current_period_end
        column :created_at
        column :updated_at
        column :stripe_id
      end
    end

    panel "Relevant Card Orders" do
      table_for shop.card_orders do
        column  :id
        column  :discount_pct
        column  :discount_exp
        column  :enabled
        column :card_side_front_id
        column :card_side_back_id
      end
    end
    active_admin_comments
  end
end
