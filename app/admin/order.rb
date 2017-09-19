ActiveAdmin.register Order do
  menu priority: 11

  actions :index, :show

  filter :shop , as: :select, collection: ->{Shop.all.sort_by {|s| s.domain}}
  filter :total_discounts
  filter :total_line_items_price
  filter :total_price
  filter :discount_codes
  filter :processed_at
  filter :postcard_id


  index do
    div class: 'top_pagination' do
      paginated_collection(collection, download_links: false)
    end

    # actions
    column :id do |order|
      link_to order.id, admin_order_path(order)
    end
    column "Disc ¢", :total_discounts
    column "Ln Itm ¢", :total_line_items_price
    column "Total ¢", :total_price
    column :customer
    column :postcard_id
    column "Shopify Id", :shopify_id
    column :discount_codes
    column :processed_at
  end

  show do
    attributes_table do
      row :shop do |order|
        order.shop
      end
      row :id
      row "Shopify Id", :shopify_id
      row :customer_id do |order|
        link_to(order.customer.id, admin_customer_path(order.customer)) if order.customer.id
      end
      row :discount_codes
      row :total_discounts
      row :total_line_items_price
      row :total_price
      row :total_tax
      row :processing_method
      row :processed_at
      row :created_at
      row :updated_at
      row :postcard_id do |order|
        link_to(order.postcard_id, admin_postcard_path(order.postcard_id)) if order.postcard_id
      end
      row :financial_status
      row :fulfillment_status
      row :tags
      row :landing_site
      row :referring_site
    end
  end
end
