class AddTotalLineItemsPriceToCheckout < ActiveRecord::Migration
  def change
    add_column :checkouts, :total_line_items_price, :integer
  end
end
