class CardSide < ApplicationRecord
  validates :is_back, inclusion: { in: [true, false] }

  mount_uploader :image, ImageUploader

  # validate :image_size

  def image_size
    debugger
    # image = MiniMagick::Image.open(image) #what is picture.path
    # unless image[:width] == 1875 && image[:height] == 1275
    #   errors.add :image, "Some info"
    # end
  end

  def show_discount?
    discount_x.present? && discount_y.present?
  end
end
