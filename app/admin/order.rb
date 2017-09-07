ActiveAdmin.register Order do
  actions :index, :show

  filter :shop , :as => :select, :collection => Shop.all.sort_by {|s| s.domain}
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

    actions
    column :id
    column :total_discounts
    column :total_line_items_price
    column :total_price
    column :customer
    column :postcard_id
    column :shopify_id, label: "Shopify Id"
    column :discount_codes
    column :processed_at
  end

  show do
    attributes_table do
      row :id
      row :shopify_id
      row :browser_ip
      row :discount_codes
      row :financial_status
      row :fulfillment_status
      row :tags
      row :landing_site
      row :referring_site
      row :total_discounts
      row :total_line_items_price
      row :total_price
      row :total_tax
      row :processing_method
      row :processed_at
      row :customer_id
      row :billing_address_id
      row :shipping_address_id
      row :created_at
      row :updated_at
      row :postcard_id
      row :shop_id
    end
  end
end
