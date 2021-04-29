class AddCreditToCardOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :card_orders, :credits, :integer, default: 0
  end
end
