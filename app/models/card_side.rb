class CardSide < ActiveRecord::Base
  validates :is_back, inclusion: { in: [true, false] }

  def show_discount?
    discount_x && discount_y
  end
end
