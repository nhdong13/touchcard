class Customer < ApplicationRecord
  has_many :orders
  has_many :postcards
  has_many :addresses

  validates :shopify_id, presence: true
  validates :shopify_id, uniqueness: true

  scope :marketing_eligible, -> { where(accepts_marketing: true) }

  def default_address
    @default_address ||= addresses.find_by(default: true) || addresses.last
  end

  def new_customer?
    orders_count.to_i <= 1
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  class << self
    def from_shopify!(shopify_customer)
      shopify_attrs = prepare_shopify_attributes(shopify_customer)
      customer = find_by(shopify_id: shopify_customer.id)

      if customer
        customer.update_attributes!(shopify_attrs)
      else
        customer = create!(shopify_attrs)
      end
      update_or_create_default_address(customer, shopify_customer)

      customer
    end

    private

    def update_or_create_default_address(customer, shopify_customer)
      existing_default = customer.addresses.find_by(default: true)
      existing_default.update_attributes!(default: false) if existing_default
      new_default_address(customer, shopify_customer)
    end

    def new_default_address(customer, shopify_customer)
      # Check if customer object responds to `default_address` method, because this isn't guaranteed
      if shopify_customer.respond_to?(:default_address) &&
         shopify_customer.default_address.blank? == false
        address = Address.from_shopify!(shopify_customer.default_address)
        address.update_attributes!(customer: customer)
      end
    end

    # Take only attributes we are using frmo shopify Customer object
    def prepare_shopify_attributes(shopify_customer)
      shopify_customer.attributes.with_indifferent_access.slice(
        :first_name,
        :last_name,
        :email,
        :verified_email,
        :total_spent,
        :tax_exempt,
        :tags,
        :orders_count,
        :note,
        :last_order_name,
        :last_order_id,
        :accepts_marketing,
        :state).merge(shopify_id: shopify_customer.id)
    end
  end
end
