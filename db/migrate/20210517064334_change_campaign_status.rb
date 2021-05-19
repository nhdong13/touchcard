class ChangeCampaignStatus < ActiveRecord::Migration[5.2]
  def change
    remove_column :card_orders, :campaign_status
    add_column :card_orders, :campaign_status, :integer, default: 0
  end
end
