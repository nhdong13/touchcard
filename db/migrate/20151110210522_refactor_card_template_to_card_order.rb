class RefactorCardTemplateToCardOrder < ActiveRecord::Migration[4.2]
  def up
    rename_column :charges, :card_template_id, :card_order_id
    rename_column :postcards, :card_template_id, :card_order_id
    rename_table :card_templates, :card_orders
  end
end
