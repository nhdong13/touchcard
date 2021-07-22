class Filter < ApplicationRecord
  belongs_to :card_order
  serialize :filter_data
  validates :card_order, :filter_data, presence: true

  before_create :cleanup_same_filter

  def cleanup_same_filter
    Filter.where(card_order_id: self.card_order_id).delete_all
  end
end
