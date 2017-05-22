ActiveAdmin.register Postcard do
  actions :index, :show

  member_action :cancel, method: :patch do
    card = Postcard.find(params[:id])
    card.cancel
    redirect_to admin_postcards_path
  end

  index do
    div class: 'top_pagination' do
      paginated_collection(collection, download_links: false)
    end

    column :discount_code
    column :send_date
    column :sent
    column :date_sent
    column :created_at
    column :updated_at
    column :paid
    column :estimated_arrival
    column :arrival_notification_sent
    column :expiration_notification_sent
    column :discount_pct
    column :discount_exp_at
    column :canceled

    actions do |card|
      link_to "Cancel", { action: 'cancel', id: card }, method: :patch unless card.canceled
    end
  end

  show do
    attributes_table :discount_code,
                     :send_date,
                     :sent,
                     :date_sent,
                     :created_at,
                     :updated_at,
                     :paid,
                     :estimated_arrival,
                     :arrival_notification_sent,
                     :expiration_notification_sent,
                     :discount_pct,
                     :discount_exp_at,
                     :canceled
  end

end
