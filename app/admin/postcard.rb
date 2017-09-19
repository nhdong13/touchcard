ActiveAdmin.register Postcard do
  menu priority: 7
  actions :index, :show

  member_action :cancel, method: :patch do
    card = Postcard.find(params[:id])
    card.cancel
    redirect_to admin_postcards_path
  end

  # Only allow filtering by shops that actually sent a postcard
  filter :shop,
         as: :select,
         collection: ->{Shop.where(id: CardOrder.where(id: Postcard.distinct
                                                             .pluck(:card_order_id))
                                       .pluck(:shop_id))
                          .sort_by {|s| s.domain}}
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

    # actions
    column :id do |postcard|
      link_to postcard.id, admin_postcard_path(postcard)
    end
    # column "Lob Id" do |postcard|
    #   link_to postcard.postcard_id, "https://dashboard.lob.com/#/postcards/#{postcard.postcard_id}" if postcard.postcard_id
    # end
    column "Disc Code", :discount_code
    column :send_date
    column :date_sent
    column :paid
    column "Est'd Arrival", :estimated_arrival
    column "Disc Pct", :discount_pct
    column "Disc Exp At", :discount_exp_at
    column :canceled

    actions do |card|
      confirmation_message = "Are you sure you want to cancel this scheduled postcard and credit the shop? This can't be undone."
      link_to "Cancel", { action: 'cancel', id: card }, method: :patch, data: { confirm: confirmation_message } unless card.canceled
    end
  end

  show do
    attributes_table do
      row :shop do |postcard|
        postcard.shop
      end
      row :id
      row :canceled
      row :card_order_id do |postcard|
        link_to postcard.card_order_id, admin_card_order_path(postcard.card_order_id) if postcard.card_order_id
      end
      row :discount_code
      row :discount_pct
      row :discount_exp_at
      row "Lob Id" do |postcard|
        link_to postcard.postcard_id, "https://dashboard.lob.com/#/postcards/#{postcard.postcard_id}"
      end
      row :sent
      row :send_date
      row :date_sent
      row :estimated_arrival
      row :created_at
      row :updated_at
      row :customer_id do |postcard|
        link_to(postcard.customer_id, admin_customer_path(postcard.customer)) if postcard.customer_id
      end
      row :order_id do |postcard|
        link_to(postcard.order_id, admin_order_path(postcard.order)) if postcard.order_id
      end
      row :paid

      row :arrival_notification_sent
      row :expiration_notification_sent
      row :price_rule_id
    end
  end
end
