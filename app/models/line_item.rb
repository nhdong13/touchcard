class LineItem < ApplicationRecord
  belongs_to :order

  validates :order, :shopify_id, :name, presence: true
  validates :shopify_id, uniqueness: true

  def self.from_shopify!(order, shopify_line_item)
    attrs = shopify_line_item.attributes.with_indifferent_access.slice(
      :fulfillable_quantity,
      :fulfillment_service,
      :fulfillment_status,
      :grams,
      :price,
      :product_id,
      :quantity,
      :requires_shipping,
      :sku,
      :title,
      :variant_id,
      :variant_title,
      :vendor,
      :name,
      :gift_card,
      :taxable,
      :total_discount
    ).merge(order: order, shopify_id: shopify_line_item.id)
    line_item = LineItem.find_by(shopify_id: shopify_line_item.id)
    if line_item.present?
      line_item.update!(attrs)
    else
      line_item = create!(attrs)
    end
    line_item
  end
end
