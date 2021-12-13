class Order < ApplicationRecord
  belongs_to :shop
  belongs_to :customer
  belongs_to :postcard  # NOT an inverse_of the trigger
  has_many :postcards, as: :postcard_trigger
  has_many :line_items
  validates :total_price, :total_tax, :shopify_id, :shop, presence: true
  validates :shopify_id, uniqueness: true

  serialize :discount_codes
  after_create :prepare_postcard_for_send

  class << self
    def from_shopify!(shopify_order, shop)
      # this one doesn't try to find the order first because that should never
      # occur since orders are only created by the new_order webhook
      attrs = shopify_order.attributes.with_indifferent_access
      customer = Customer.from_shopify!(attrs[:customer]) if attrs[:customer]
      shopify_attrs = attrs.slice(
        :browser_ip,
        :financial_status,
        :fulfillment_status,
        :tags,
        :landing_site,
        :referring_site,
        :processing_method,
        :processed_at
      ).merge(
        total_discounts: shopify_order.total_discounts.to_f * 100,
        total_line_items_price: shopify_order.total_line_items_price.to_f * 100,
        total_price: shopify_order.total_price.to_f * 100,
        total_tax: shopify_order.total_tax.to_f * 100,
        discount_codes: shopify_order.discount_codes.map(&:attributes),
        shopify_id: shopify_order.id,
        customer: customer,
        shop: shop
      )

      order = Order.find_by(shopify_id: shopify_order.id)
      if order.present?
        order.update!(shopify_attrs)
      else
        order = create!(shopify_attrs)
      end

      shopify_order.line_items.each { |li| LineItem.from_shopify!(order, li) }
      order
    end
  end

  def connect_to_postcard
    # This method tracks the postcard whose discount was used, if any. It's not related to postcard_trigger (the connected postcard would have been triggered by another order)
    # TODO: This speeds up the revenue query. Instead we should probably calculate that as an occasional batch job, rather than on the fly via this awkward relation
    postcard = find_postcard_by_discount
    update!(postcard: postcard) if postcard
    postcard
  end

  def find_postcard_by_discount
    return if discount_codes.blank?
    codes = discount_codes.map { |dc| dc["code"].upcase }
    Postcard.find_by(discount_code: codes, sent: true)
  end

  def international
    customer.default_address.country_code.present? && customer.default_address.country_code != "US"
  end

  # Custom active_admin filter order by discount code in url /admin/orders
  def self.ransackable_scopes(_auth_object = nil)
    %i(filter_orders_by_discount)
  end
  
  def self.filter_orders_by_discount(discount_code)
    where("discount_codes like ?", "%#{discount_code}%")
  end

  private
  def prepare_postcard_for_send
    PreparePostcardJob.perform_later(id)
  end
end
