class PostcardSerializer < ActiveModel::Serializer
  attributes :id, :card_order_id, :discount_code, :order_id, :customer_id, :customer_name,
    :addr1, :addr2, :city, :state, :country, :zip, :send_date, :sent, :date_sent,
    :postcard_id, :return_customer, :purchase2

  has_one :card_order, embed: :ids
end
