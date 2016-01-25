class LineItemSerializer < ActiveModel::Serializer
  attributes :id, :order_id, :price, :quantity, :name, :customer_name, :created_at

  def customer_name
    object.order.customer.try(:full_name)
  end
end
