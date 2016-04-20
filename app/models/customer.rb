class Customer < ActiveRecord::Base
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
    def from_shopify!(customer)
      create_attrs = customer.attributes.with_indifferent_access.slice(
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
        :state,
        :default).merge(shopify_id: customer.id)
      # update or create default address
      inst = find_by(shopify_id: customer.id)
      if inst
        inst.update_attributes!(create_attrs)
      else
        inst = create!(create_attrs)
      end
      existing_default = inst.addresses.find_by(default: true)
      existing_default.update_attributes!(default: false) if existing_default
      return inst unless customer.default_address
      address = Address.from_shopify!(customer.default_address)
      address.update_attributes!(customer: inst)
      inst
    end
  end
end
