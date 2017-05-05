ActiveAdmin.register Filter do

  index do
    column :id
    column :created_at
    column :updated_at
  end

  show do
    attributes_table :id, :created_at, :updated_at
  end
  
end
