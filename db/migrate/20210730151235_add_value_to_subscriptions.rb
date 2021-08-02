# This migration is used for convert the old token into new dollar credit
class AddValueToSubscriptions < ActiveRecord::Migration[6.1]
  def change
    add_column :subscriptions, :value, :float, default: 0
    # Init subscription dollar value into Subscription table and set current current value for each
    Subscription.all.each{|sub| sub.update(value: sub.quantity * sub.plan.amount.to_f / 100)}
    # Convert all shops current credit from token credit into dollar credit
    Shop.all.each{|shop| shop.update(credit: shop.credit * shop.current_subscription.plan.amount.to_f / 100) if shop.current_subscription.present?}
  end
end
