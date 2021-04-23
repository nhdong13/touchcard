class CustomerTargetingService
  attr_accessor :current_shop, :orders
  def initialize(shop)
    @current_shop = shop
    @orders = @current_shop.orders.where.not(customer_id: nil)
  end

  def get_customer_ids filter, condition, value
    collection = select_collection(filter)
    filter_by(collection, condition, value)
  end

  def find(accepted_attrs, removed_attrs)
    @user_orders_count = orders.group(:customer_id).count
    @user_spends_count = orders.group(:customer_id).sum(:total_line_items_price)
    @user_last_orders = orders.group(:customer_id).maximum(:processed_at)
    @user_first_orders = orders.group(:customer_id).minimum(:processed_at)
    @user_last_order_totals = {}
    orders.filter do |order|
      processed_time = @user_last_orders[order.customer_id]
      processed_time.present? && processed_time == order.processed_at
    end.each{|i| @user_last_order_totals[i.customer_id] = i.total_line_items_price}

    build_list(accepted_attrs, removed_attrs)
  end

  def build_list accepted_attrs, removed_attrs
    accepted_user_ids = {}
    removed_user_ids = []

    unless accepted_attrs.present?
      orders.pluck(:customer_id).each{|id| accepted_user_ids[id] = []}
    else
      accepted_attrs[:filter].each_with_index do |filter, i|
        ids = get_customer_ids(filter, accepted_attrs[:condition][i], accepted_attrs[:value][i])
        ids.each do |id|
          accepted_user_ids[id] = Array.new(accepted_attrs[:filter].size) unless accepted_user_ids[id].present?
          accepted_user_ids[id][i] = "X"
        end
      end
    end

    removed_attrs[:filter].each_with_index do |filter, i|
      removed_user_ids += get_customer_ids(filter, removed_attrs[:condition][i], removed_attrs[:value][i])
    end if removed_attrs.present?
    removed_user_ids.each{|remove_id| accepted_user_ids.delete(remove_id)}
    Customer.find(accepted_user_ids.keys).each{|customer| accepted_user_ids[customer.id].unshift(customer.full_name)}
    accepted_user_ids
  end

  def build_csv list, titles
    @csv = ExportCsvService.new(list, titles).perform
  end

  def select_collection filter
    case filter
    when "number_of_order"
      @user_orders_count
    when "total_spend"
      @user_spends_count
    when "last_order_date"
      @user_last_orders
    when "first_order_date"
      @user_first_orders
    when "last_order_total"
      @user_last_order_totals
    else
      []
    end
  end

  def filter_by collection, filter_type, raw_value
    case filter_type
      when "0"
        value = raw_value.to_i
        collection.filter{|k,v| v == value}.keys
      when "1"
        value = raw_value.to_i
        collection.filter{|k,v| v > value}.keys
      when "2"
        value = raw_value.to_i
        collection.filter{|k,v| v < value}.keys
      when "3"
        value = raw_value.to_time.end_of_day
        collection.filter{|k,v| v < value}.keys
      when "4"
        begin_value = raw_value[0].to_time.beginning_of_day
        end_value = raw_value[1].to_time.end_of_day
        collection.filter{|k,v| (v < begin_value) && (v > end_value)}.keys
      when "5"
        value = raw_value.to_time.beginning_of_day
        collection.filter{|k,v| v > value}.keys
      when "6"
        value = raw_value.to_i.days
        collection.filter{|k,v| v > Time.now.beginning_of_day - value}.keys
      when "7"
        begin_value = raw_value[0].to_i.days
        end_value = raw_value[1].to_i.days
        collection.filter{|k,v| (v > Time.now.beginning_of_day - begin_value) && (v < Time.now.end_of_day - end_value)}.keys
      when "8"
        value = raw_value.to_i.days
        collection.filter{|k,v| v < Time.now.end_of_day - value}.keys
      else []
    end
  end
end
