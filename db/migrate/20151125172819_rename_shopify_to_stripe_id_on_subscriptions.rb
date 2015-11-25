class RenameShopifyToStripeIdOnSubscriptions < ActiveRecord::Migration
  def change
    rename_column :shops, :shopify_id, :stripe_id
  end
end
