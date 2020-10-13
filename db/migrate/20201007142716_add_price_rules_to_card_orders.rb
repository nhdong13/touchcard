class AddPriceRulesToCardOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :card_orders, :price_rules, :json, default: {}
  end
end
