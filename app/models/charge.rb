require "customer_check"

class Charge < ActiveRecord::Base
  belongs_to :shop
  belongs_to :card_order

  validates :shop_id, presence: true
  validate :customer_number, on: :create

  after_initialize :ensure_defaults

  def ensure_defaults
    self.token ||= SecureRandom.urlsafe_base64(32)
  end

  def bulk?
    !recurring?
  end

  def price
    (amount.to_i * 0.99).round(2)
  end

  def customer_number
    return if recurring?
    expected_amount = get_customer_number(shop,
      card_order.start_date,
      card_order.end_date)
    amount_error_message = "Amount does not match shop data"
    errors.add(:amount, amount_error_message) unless amount == expected_amount
  end

  def create_shopify_charge
    shop.new_sess
    klass = ShopifyAPI::ApplicationCharge
    create_params = {
      price: price,
      return_url: "https://touchcard.herokuapp.com/api/v1/charges/#{id}/activate?token=#{token}",
      test: !Rails.env.production?,
      name: "Touchcard Bulk Send"
    }
    if recurring?
      klass = ShopifyAPI::RecurringApplicationCharge
      create_params[:name] = "Touchcard Monthly Plan"
    end
    shopify_charge = klass.create(create_params)
    update_attributes!(
      shopify_redirect: shopify_charge.confirmation_url,
      status: "pending",
      shopify_id: shopify_charge.id
    )
  end

  def cancel
    # Update the shop
    shop.update_attributes(charge_id: nil, charge_amount: 0, charge_date: nil)

    # Delete the plan on shopify
    shop.new_sess
    ShopifyAPI::RecurringApplicationCharge.delete(shopify_id)

    # Update self's data
    update_attributes(shopify_id: nil, shopify_redirect: nil)
  end

  def shopify_charge
    return ShopifyAPI::RecurringApplicationCharge.find(shopify_id) if recurring?
    ShopifyAPI::ApplicationCharge.find(shopify_id)
  end

  def activate
    fail "unexpected shopify charge status #{shopify_charge.status}"
    update_attribute(:status, shopify_charge.status)
    return unless shopify_charge.status == "accepted"
    shopify_charge.activate
    update_attribute(:status, "active")
    return activate_recurring_charge if recurring?
    activate_bulk_charge
  end

  def activate_bulk_charge
    # Do the bulk send
    card_order.update_attributes(status: "sending")
    card_order.bulk_send
  end

  def activate_recurring_charge
    # Find the charge on Shopify's end, and check that it is accepted
    old_charge = Charge.find_by(
      status: "active",
      recurring: true,
      shop_id: shop.id
    )
    old_charge.update_attribute(:status, "cancelled")

    # Update shop data and credits
    shop.update_attributes(
      charge_id: id,
      amount: amount,
      charge_date: Date.today)
    shop.top_up
  end
end
