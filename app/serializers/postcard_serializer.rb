class PostcardSerializer < ActiveModel::Serializer
  attributes :id,
    :customer_name, :addr1, :addr2, :city, :state, :country, :zip,
    :send_date, :sent, :date_sent,
    :return_customer, :purchase2,
    :card_order_id
end
