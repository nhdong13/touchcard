ActiveAdmin.register Postcard do
  actions :index, :show


  filter :shop
  filter :discount_code
  filter :send_date
  filter :sent
  filter :date_sent
  filter :created_at
  filter :estimated_arrival
  filter :canceled
  filter :price_rule
  filter :discount_pct


  index do
    div class: 'top_pagination' do
      paginated_collection(collection, download_links: false)
    end

    actions

    column :id
    column :postcard_id do |postcard|
      link_to postcard.postcard_id, "https://dashboard.lob.com/#/postcards/#{postcard.postcard_id}"
    end
    column :discount_code
    column :send_date
    column :sent
    column :date_sent
    column :paid
    column :estimated_arrival
    column :discount_pct
    column :discount_exp_at
    column :canceled
  end

  show do
    attributes_table do
      row :id
      row :card_order_id
      row :discount_code
      row :send_date
      row :sent
      row :date_sent
      row :postcard_id do |postcard|
        link_to postcard.postcard_id, "https://dashboard.lob.com/#/postcards/#{postcard.postcard_id}"
      end


      row :created_at
      row :updated_at
      row :customer_id
      row :order_id
      row :paid
      row :estimated_arrival
      row :arrival_notification_sent
      row :expiration_notification_sent
      row :discount_pct
      row :discount_exp_at
      row :canceled
      row :price_rule_id
    end
  end



end
