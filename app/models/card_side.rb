class CardSide < ApplicationRecord

  belongs_to :card_order

  validates :is_back, inclusion: { in: [true, false] }

  def show_discount?
    discount_x.present? && discount_y.present?
  end
end
