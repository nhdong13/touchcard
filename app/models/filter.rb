class Filter < ApplicationRecord
  belongs_to :card_order
  serialize :filter_data
  validates :card_order, :filter_data, presence: true
  after_save :cleanup_same_filter

  def cleanup_same_filter
    Filter.where.not(id: self.id).where(card_order_id: self.card_order_id).delete_all
  end
end
