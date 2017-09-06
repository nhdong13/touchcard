ActiveAdmin.register CardSide do
  actions :index, :show
  menu false

  index do
    column :id
    column :image
    column :preview
    column :is_back
    column :created_at
    column :updated_at
    column :discount_y
    column :discount_x
    actions
  end

  show do
    attributes_table do
      row :id
      row :image do |card_side|
        link_to card_side.image, card_side.image if card_side.image
      end
      row :preview
      row :is_back
      row :created_at
      row :updated_at
      row :discount_y
      row :discount_x
    end
  end
end
