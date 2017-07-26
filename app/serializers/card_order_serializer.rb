class CardOrderSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :shop_id, :type,
    :enabled, :international,
    :discount_pct, :discount_exp,
    :send_delay, :arrive_by,
    :customers_before, :customers_after,
    :status, :cards_sent, :revenue,
    :cards_sent_total

  has_many :filters, serializer: FilterSerializer
  has_one :card_side_front, root: :card_sides, serializer: CardSideSerializer
  has_one :card_side_back, root: :card_sides, serializer: CardSideSerializer
end
