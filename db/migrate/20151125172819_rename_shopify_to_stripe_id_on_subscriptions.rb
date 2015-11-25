class RenameShopifyToStripeIdOnSubscriptions < ActiveRecord::Migration
  def change
    rename_column :subscriptions, :shopify_id, :stripe_id
  end
end
