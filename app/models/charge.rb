class Charge < ActiveRecord::Base
  belongs_to :shop
  belongs_to :card_template

  validates :shop_id, presence: true
  # TODO validation for customer number

  def new_shopify_charge
    shop = self.shop
    shop.new_sess

    shopify_charge = ShopifyAPI::ApplicationCharge.create(
      name: "Touchcard Bulk Send",
      price: self.amount,
      test: true,
      return_url: "https://touchcard.herokuapp.com/charge/activate_bulk"
    )

    self.update_attributes(:shopify_id => shopify_charge.id)
  end

  def canceling
    self.update_attribute(:status, "canceling")
  end
end
