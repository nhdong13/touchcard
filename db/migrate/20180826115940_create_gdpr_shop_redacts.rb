class CreateGdprShopRedacts < ActiveRecord::Migration[4.2]
  def change
    create_table :gdpr_shop_redacts do |t|
      t.bigint :shop_shopify_id
      t.string :shop_domain

      t.timestamps null: false
    end
  end
end
