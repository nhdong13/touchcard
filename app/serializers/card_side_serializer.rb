class CardSideSerializer < ActiveModel::Serializer
  attributes :id, :image, :discount_x, :discount_y
end
