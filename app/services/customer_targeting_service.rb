class CustomerTargetingService
  attr_accessor :current_shop, :orders
  def initialize(shop)
    @current_shop = shop
    @orders = @current_shop.orders
  end

  def find(accepted_attrs, removed_attrs)
    user_orders_count = orders.group(:customer_id).count
    accepted_user_ids = []
    removed_user_ids = []
    unless accepted_attrs.present?
      accepted_user_ids = orders.pluck(:customer_id)
    else
      accepted_attrs[:condition].each_with_index do |condition, i|
        accepted_user_ids += filter(user_orders_count, condition, accepted_attrs[:value][i].to_i)
      end
    end

    removed_attrs[:condition].each_with_index do |condition, i|
      removed_user_ids += filter(user_orders_count, condition, removed_attrs[:value][i].to_i)
    end if removed_attrs.present?

    Customer.find(accepted_user_ids - removed_user_ids)
  end

  def filter orders_count, filter_type, value
    case filter_type
      when "0"
        orders_count.filter{|k,v| v == value}.keys
      when "1"
        orders_count.filter{|k,v| v > value}.keys
      when "2"
        orders_count.filter{|k,v| v < value}.keys
      else []
    end
  end
end
