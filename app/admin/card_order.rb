ActiveAdmin.register CardOrder do
  includes :card_side_front
  includes :card_side_back

  actions :index, :show

  remove_filter :postcards
  remove_filter :card_side_front
  remove_filter :card_side_back
  remove_filter :shop
  remove_filter :filters

  index do
    column :type
    column :discount_pct
    column :discount_exp
    column :enabled
    column :international
    column :send_delay
    column :arrive_by
    column :customers_before
    column :customers_after
    column :status
    column :created_at
    column :updated_at
  end

  show do
    attributes_table :type,
                     :discount_pct,
                     :discount_exp,
                     :enabled,
                     :international,
                     :send_delay,
                     :arrive_by,
                     :customers_before,
                     :customers_after,
                     :status,
                     :created_at,
                     :updated_at
  end

end
