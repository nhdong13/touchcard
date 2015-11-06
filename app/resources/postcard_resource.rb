class PostcardResource < JSONAPI::Resource
  has_one :shop, though: :card_template
  belongs_to :card_template

  attributes :coupon, :order_id, :customer_id, :customer_name, :addr1, :addr2, :city, :state,
    :country, :zip, :send_date, :sent, :date_sent, :postcard_id, :return_customer, :purchase2
end
