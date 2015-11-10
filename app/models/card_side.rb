class CardSide < ActiveRecord::Base
  validates :image, :is_back, presence: true
end
