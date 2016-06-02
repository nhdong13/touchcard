class Checkout < ActiveRecord::Base
  belongs_to :shop
  belongs_to :customer
  has_many :postcards, as: :postcard_triggerable

  validates :shopify_id, :abandoned_checkout_url, :token, :total_price,
            :customer_id, :shop_id, presence: true
  validates :shopify_id, uniqueness: true

  def international
    customer.default_address.country_code != "US"
  end

  class << self
    def from_shopify(checkout, shop)
      attrs = checkout.attributes.with_indifferent_access
      customer = Customer.from_shopify!(attrs[:customer]) if attrs[:customer]
      row = attrs.slice(
        :abandoned_checkout_url,
        :cart_token,
        :closed_at,
        :completed_at,
        :token,
        :total_price
      ).merge(
        shopify_id: checkout.id,
        customer: customer,
        shop: shop)
      Checkout.create(row)
    end
  end

end
