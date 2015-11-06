class CardTemplateResource < JSONAPI::Resource
  belongs_to :shop
  has_many :postcards

  attributes :type, :style, :logo, :image_front, :image_back, :logo, :title_front, :text_front,
    :preview_front, :preview_back, :coupon_pct, :coupon_exp, :coupon_loc, :enabled, :international,
    :send_delay, :arrive_by, :customers_before, :customers_after, :transaction_id, :status,
    :cards_sent, :revenue
end
