class LineItem < ApplicationRecord
  belongs_to :order

  validates :order, :shopify_id, :name, presence: true
  validates :shopify_id, uniqueness: true

  def self.from_shopify!(order, line_item)
    attrs = line_item.attributes.with_indifferent_access
    select_attrs = attrs.slice(
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
    ).merge(order: order, shopify_id: line_item.id)
    db_line_item = LineItem.find_by_shopify_id(line_item.id)
    inst = if db_line_item.present?
      update!(select_attrs)
    else
      create!(select_attrs)
    end
    inst
  end
end
