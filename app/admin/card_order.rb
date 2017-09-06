ActiveAdmin.register CardOrder do
  actions :index, :show

  filter :shop
  filter :discount_pct
  filter :discount_exp
  filter :enabled
  filter :international
  filter :send_delay
  filter :created_at
  filter :updated_at

  index do
    actions

    column :id
    column :type
    column :discount_pct
    column :discount_exp
    column :enabled
    column :international
    column :send_delay
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
                     :created_at,
                     :updated_at


    panel "Card Sides" do
      table_for card_order.card_side_front do
        column :id do |side|
          link_to side.id, controller: "card_sides", action: "show", id: side.id
        end
        column :image do |card_side|
          link_to card_side.image, card_side.image if card_side.image
        end
        column :is_back
        column :discount_y
        column :discount_x
      end
      table_for card_order.card_side_back do
        column :id do |side|
          link_to side.id, controller: "card_sides", action: "show", id: side.id
        end
        column :image do |card_side|
          link_to card_side.image, card_side.image if card_side.image
        end
        column :is_back
        column :discount_y
        column :discount_x
      end
    end


    panel "Filter Data" do
      table_for card_order.filters do
        column :id
        column :created_at
        column :updated_at
        column :card_order
        column :filter_data
      end
    end

  end
end
