class CardSide < ActiveRecord::Base
  validates :is_back, inclusion: { in: [true, false] }

  mount_uploader :image, ImageUploader

  def show_discount?
    discount_x.present? && discount_y.present?
  end
end
