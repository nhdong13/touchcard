class ChangeDefaultCampaignType < ActiveRecord::Migration[5.2]
  def change
    change_column :card_orders, :campaign_type , :integer, default: nil
  end
end
