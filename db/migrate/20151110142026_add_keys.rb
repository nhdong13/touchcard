class AddKeys < ActiveRecord::Migration
  def change
    add_foreign_key "card_templates", "shops"
    add_foreign_key "charges", "card_templates"
    add_foreign_key "charges", "shops"
    add_foreign_key "postcards", "card_templates"
    add_foreign_key "card_templates", "card_sides", column: :card_side_front_id
    add_foreign_key "card_templates", "card_sides", column: :card_side_back_id
  end
end
