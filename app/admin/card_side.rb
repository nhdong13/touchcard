ActiveAdmin.register CardSide do

  index do
    column :id
    column :image
    column :preview
    column :is_back
    column :created_at
    column :updated_at
    column :discount_y
    column :discount_x
  end

  show do
    attributes_table :id,
                     :image,
                     :preview,
                     :is_back,
                     :created_at,
                     :updated_at,
                     :discount_y,
                     :discount_x
  end

end
