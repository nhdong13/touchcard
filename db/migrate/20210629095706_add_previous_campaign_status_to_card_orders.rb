class AddPreviousCampaignStatusToCardOrders < ActiveRecord::Migration[6.1]
  def change
    add_column :card_orders, :previous_campaign_status, :integer, default: nil
  end
end
