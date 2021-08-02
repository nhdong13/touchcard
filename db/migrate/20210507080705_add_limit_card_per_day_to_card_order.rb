class AddLimitCardPerDayToCardOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :card_orders, :limit_cards_per_day, :integer
  end
end
