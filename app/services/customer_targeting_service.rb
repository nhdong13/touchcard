class CustomerTargetingService
  attr_accessor :current_shop, :orders
  def initialize(shop)
    @current_shop = shop
    @orders = @current_shop.orders.where.not(customer_id: nil)
  end

  def find(accepted_attrs, removed_attrs)
    user_orders_count = orders.group(:customer_id).count
    user_spends_count = orders.group(:customer_id).sum(:total_line_items_price)
    accepted_user_ids = orders.pluck(:customer_id)
    removed_user_ids = []

    unless accepted_attrs.present?
      accepted_user_ids = orders.pluck(:customer_id)
    else
      accepted_attrs[:filter].each_with_index do |filter, i|
        collection = case filter
        when "0"
          user_orders_count
        when "1"
          user_spends_count
        else
          []
        end
        filtered_user_ids = filter_by(collection, accepted_attrs[:condition][i], accepted_attrs[:value][i].to_i)
        accepted_user_ids = accepted_user_ids.select{|id| filtered_user_ids.index(id).present?}
      end
    end

    removed_attrs[:filter].each_with_index do |filter, i|
      collection = case filter
      when "0"
        user_orders_count
      when "1"
        user_spends_count
      else
        []
      end
      removed_user_ids += filter_by(collection, accepted_attrs[:condition][i], accepted_attrs[:value][i].to_i)
    end if removed_attrs.present?

    Customer.find(accepted_user_ids - removed_user_ids)
  end

  def filter_by collection, filter_type, value
    case filter_type
      when "0"
        collection.filter{|k,v| v == value}.keys
      when "1"
        collection.filter{|k,v| v > value}.keys
      when "2"
        collection.filter{|k,v| v < value}.keys
      else []
    end
  end
end
