class Customer < ApplicationRecord
  has_many :orders
  has_many :postcards
  has_many :addresses
  has_many :shops, through: :orders
  has_many :checkouts

  validates :shopify_id, presence: true
  validates :shopify_id, uniqueness: true

  scope :marketing_eligible, -> { where(accepts_marketing: true) }

  def default_address
    @default_address ||= addresses.find_by(default: true) || addresses.last
  end

  def new_customer?(shop_id=nil)
    orders_count.to_i <= 1 && Order.where(shop_id: shop_id, customer_id: id).count <= 1
  end

  def international?
    default_address.country_code.present? && default_address.country_code != "US"
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  class << self
    def from_shopify!(shopify_customer)
      shopify_attrs = prepare_shopify_attributes(shopify_customer)
      customer = find_by(shopify_id: shopify_customer.id)

      if customer
        customer.update!(shopify_attrs)
      else
        customer = create!(shopify_attrs)
      end
      update_or_create_default_address(customer, shopify_customer)

      customer
    end

    private

    def update_or_create_default_address(customer, shopify_customer)
      existing_default = customer.addresses.find_by(default: true)
      existing_default.update!(default: false) if existing_default
      new_default_address(customer, shopify_customer)
    end

    def new_default_address(customer, shopify_customer)
      # Check if customer object responds to `default_address` method, because this isn't guaranteed
      if shopify_customer.respond_to?(:default_address) &&
         shopify_customer.default_address.blank? == false
        address = Address.from_shopify!(shopify_customer.default_address)
        address.update!(customer: customer)
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

  def eligible_for_winback_postcard(start_date, end_date)
    last_order_date.between?(start_date, end_date)
  end

  def have_postcard_for_card(card)
    Postcard.joins(:card_order)
            .where(card_orders: { type: card.type }, card_order_id: card.id, customer_id: id)
            .any?
  end

  def last_order_date
    orders.order("created_at DESC").first.created_at.to_date
  end
end
