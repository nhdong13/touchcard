class AddIsDiscountClaimedToPostcards < ActiveRecord::Migration[6.1]
  def change
    add_column :postcards, :is_discount_claimed, :boolean, default: false
    Postcard.find_each do |pc|
      pc.update(is_discount_claimed: true) if pc.orders.present?
    end
  end
end
