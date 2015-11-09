class Charge < ActiveRecord::Base
  belongs_to :shop
  belongs_to :card_template

  validates :shop_id, presence: true
  validates :customer_number, on: :create, unless: :recurring?

  def customer_number
    require 'customer_check'
    unless amount == get_customer_number(@current_shop, start_date, end_date)
      errors.add(:amount, "Amount does not match shop data")
    end
  end

  def new_shopify_charge
    shop = self.shop
    shop.new_sess

    if self.recurring?
      price = (self.amount.to_i * 0.99).round(2)

      #Set charge values
      name = "Touchcard Monthly Plan"
      test = true #NOTE: Change this to false for live plans
      return_url = "https://touchcard.herokuapp.com/api/v1/charges/activate"

      #Create application charge on Shopify
      shopify_charge = ShopifyAPI::RecurringApplicationCharge.create(
        name: name,
        price: price,
        test: test,
        return_url: return_url
      )

      #Save the charge info to the local db and go to Shopify confirmation url
      self.update_attributes(shopify_charge: shopify_charge.id, shopify_redirect: shopify_charge.confirmation_url, status: "pending")

    else
      shopify_charge = ShopifyAPI::ApplicationCharge.create(
        name: "Touchcard Bulk Send",
        price: self.amount,
        test: true,
        return_url: "https://touchcard.herokuapp.com/api/v1/charges/activate"
      )
    end

    self.update_attributes(:shopify_id => shopify_charge.id)
  end

  def cancel_plan
    # Update the shop
    shop = self.shop
    shop.update_attributes(charge_id: nil, charge_amount: 0, charge_date: nil)

    # Delete the plan on shopify
    shop.new_sess
    ShopifyAPI::RecurringApplicationCharge.delete(self.shopify_id)

    # Update self's data
    self.update_attributes(:shopify_id => nil, :shopify_redirect => nil)
  end
end
