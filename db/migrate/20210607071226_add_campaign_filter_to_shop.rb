class AddCampaignFilterToShop < ActiveRecord::Migration[6.1]
  def change
    add_column :shops, :campaign_filter_option, :json, default: {}
  end
end
