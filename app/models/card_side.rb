class CardSide < ActiveRecord::Base
  validates :is_back, inclusion: { in: [true, false] }
end
