class LineItemSerializer < ActiveModel::Serializer
  attributes :id, :order_id, :price, :quantity, :title, :customer_name, :created_at

  def customer_name
    object.order.customer.try(:name)
  end
end
