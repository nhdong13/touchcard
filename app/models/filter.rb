class Filter < ApplicationRecord
  belongs_to :card_order
  serialize :filter_data
  validates :card_order, :filter_data, presence: true
end
