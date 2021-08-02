class CreatePostCardInfos < ActiveRecord::Migration[5.2]
  def change
    create_table :post_card_infos do |t|
      t.string :campaign_id
      t.string :front_design
      t.string :back_design
      t.timestamps
    end
  end
end
