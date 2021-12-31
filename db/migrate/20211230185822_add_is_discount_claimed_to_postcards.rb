class AddIsDiscountClaimedToPostcards < ActiveRecord::Migration[6.1]
  def change
    add_column :postcards, :is_discount_claimed, :boolean, default: false
    CardOrder.unscoped do
      Postcard.includes(:orders).find_each do |pc|
        if pc.orders.present?
          pc.is_discount_claimed = true
          pc.save(validate: false)
        end
      end
    end
  end
end
