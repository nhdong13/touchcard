class AddTotalLineItemsPriceToCheckout < ActiveRecord::Migration[4.2]
  def change
    add_column :checkouts, :total_line_items_price, :integer
  end
end
