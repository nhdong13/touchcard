class Order < ActiveRecord::Base
  belongs_to :customer
  belongs_to :postcard
  validates :total_price, :total_tax, :shopify_id, presence: true
  validates :shopify_id, uniqueness: true

  serialize :discount_codes

  class << self
    def from_shopify!(order)
      # this one doesn't try to find the order first because that should never
      # occur since orders are only created by the new_order webhook
      attrs = order.attributes.with_indifferent_access
      customer = Customer.from_shopify!(attrs[:customer]) if attrs[:customer]
      create!(attrs.slice(
        :browser_ip,
        :financial_status,
        :fulfillment_status,
        :tags,
        :landing_site,
        :referring_site,
        :processing_method,
        :processed_at
      ).merge(
        total_discounts: order.total_discounts.to_f * 100,
        total_line_items_price: order.total_line_items_price.to_f * 100,
        total_price: order.total_price.to_f * 100,
        total_tax: order.total_tax.to_f * 100,
        discount_codes: order.discount_codes.map(&:attributes),
        shopify_id: order.id,
        customer: customer))
    end
  end

  def connect_to_postcard
    postcard = find_postcard_by_discount
    return update_attributes!(postcard: postcard) if postcard
    postcard = Postcard.where("
      customer_id = ? AND
      order_id != ? AND
      sent = TRUE", customer_id, id).first
    update_attributes!(postcard: postcard) if postcard
    postcard
  end

  def find_postcard_by_discount
    return if discount_codes.blank?
    codes = discount_codes.map { |dc| dc["code"] }
    Postcard.find_by(discount_code: codes, sent: true)
  end
end