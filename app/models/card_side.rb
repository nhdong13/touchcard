class CardSide < ActiveRecord::Base
  validates :image, presence: true
  validates :is_back, inclusion: { in: [true, false] }
end
