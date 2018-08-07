class AddLifetimePurchaseThresholdToCardOrders < ActiveRecord::Migration[4.2]
  def change
    add_column :card_orders, :lifetime_purchase_threshold, :integer
  end
end
