class RenameShopifyToStripeIdOnSubscriptions < ActiveRecord::Migration[4.2]
  def change
    rename_column :subscriptions, :shopify_id, :stripe_id
  end
end
