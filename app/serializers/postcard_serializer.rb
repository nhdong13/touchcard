class PostcardSerializer < ActiveModel::Serializer
  embed :ids

  attributes :id, :card_template, :coupon, :order_id, :customer_id, :customer_name,
    :addr1, :addr2, :city, :state, :country, :zip, :sent_date, :sent, :date_sent,
    :postcard_id, :return_customer, :purchase2

  has_one :card_template
end
