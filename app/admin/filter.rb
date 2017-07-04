ActiveAdmin.register Filter do
  actions :index, :show

  remove_filter :card_order

  index do
    column :id
    column :created_at
    column :updated_at
    actions
  end

  show do
    attributes_table :id, :created_at, :updated_at
  end

end
