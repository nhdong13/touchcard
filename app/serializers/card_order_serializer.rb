class CardOrderSerializer < ActiveModel::Serializer
  attributes :id, :shop_id, :type, :style, :image_front, :image_back, :logo,
    :title_front, :text_front, :preview_front, :preview_back, :discount_pct,
    :discount_exp, :discount_loc, :enabled, :international, :send_delay, :arrive_by,
    :customers_before, :customers_after, :transaction_id, :status, :cards_sent,
    :revenue

  has_one :shop, embed: :ids
  has_many :postcards, embed: :ids
end
