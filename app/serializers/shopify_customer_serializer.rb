class ShopifyCustomerSerializer < ActiveModel::Serializer
  attributes :customer_count, :start_date, :end_date
end
