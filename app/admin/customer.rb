ActiveAdmin.register Customer do
  menu priority: 13
  actions :index, :show
  # menu false

  # filter :shop , as: :select, collection: ->{Shop.all.sort_by {|s| s.domain}}
  filter :first_name
  filter :last_name
  filter :email
  filter :total_spent
  filter :orders_count
  filter :accepts_marketing
  filter :created_at
  filter :updated_at

  index do
    column :id do |customer|
      link_to customer.id, admin_customer_path(customer)
    end
    column "Shopify Id", :shopify_id
    column "First", :first_name
    column "Last", :last_name
    column :total_spent
    column :tags
    column :orders_count
    column :last_order_id
    column :accepts_marketing
    column :created_at
    column :updated_at
  end

  show do
    attributes_table do
      row :shop do |customer|
        order = Order.find_by(shopify_id: customer.last_order_id)
        order.shop
      end
      row :id
      row "Shopify Id", :shopify_id
      row :first_name
      row :last_name
      row :email
      row :verified_email
      row :total_spent
      row :tax_exempt
      row :tags
      row :state
      row :orders_count
      row :note
      row :last_order_name
      row "Last Order (Shopify Id)" do |customer|
        order = Order.find_by(shopify_id: customer.last_order_id)
        link_to customer.last_order_id, admin_order_path(order) if customer.last_order_id
      end
      row :accepts_marketing
      row :created_at
      row :updated_at
    end

    panel "Addresses" do
      table_for customer.addresses do
        column :id do |address|
          link_to(address.id, admin_address_path(address)) if address.id
        end
        column :first_name
        column :last_name
        column :province_code
        column :country_code
        column :customer_id
        column :default
      end
    end
  end
end
