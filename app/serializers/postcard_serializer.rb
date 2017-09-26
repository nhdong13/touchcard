class PostcardSerializer < ActiveModel::Serializer
  attributes :id,
    :customer_name, :addr1, :addr2, :city, :state, :country, :zip,
    :send_date, :sent, :date_sent, :revenue, :card_order_id, :is_paid, :canceled

  def is_paid
    object.paid?
  end

  def customer_name
    object.address.name
  end

  def addr1
    object.address.address1
  end

  def addr2
    object.address.address2
  end

  def city
    object.address.city
  end

  def state
    object.address.province
  end

  def country
    object.address.country
  end

  def zip
    object.address.zip
  end
end
