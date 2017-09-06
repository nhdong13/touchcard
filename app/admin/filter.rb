ActiveAdmin.register Filter do
  actions :index, :show
  menu false

  remove_filter :card_order

  index do
    column :id
    column :created_at
    column :updated_at
    column :card_order
    column :filter_data
    actions
  end

  show do
    attributes_table :id, :created_at, :updated_at
  end
end
