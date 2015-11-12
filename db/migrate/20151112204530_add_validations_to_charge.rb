class AddValidationsToCharge < ActiveRecord::Migration
  def change
    change_column :charges, :card_order_id, :integer, null: false
    change_column :charges, :shop_id, :integer, null: false
    change_column :charges, :amount, :integer, null: false
    change_column :charges, :last_page, :text, null: false
    change_column :charges, :status, :text, null: false
  end
end
