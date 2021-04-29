class AddCampaignTypeToCardOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :card_orders, :campaign_type , :integer, default: 0
    CardOrder.where(budget: nil).update_all(budget: 0)
  end
end
