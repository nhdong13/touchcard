class AddLifetimePurchaseThresholdToCardOrders < ActiveRecord::Migration
  def change
    add_column :card_orders, :lifetime_purchase_threshold, :integer
  end
end
