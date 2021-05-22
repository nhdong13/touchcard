class CustomerTargetingService
  attr_accessor :current_shop, :orders
  def initialize(shop=nil)
    if shop
      @current_shop = shop
      @orders = shop.orders.where.not(customer_id: nil)
    end
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
    @user_shipping_countries = {}
    orders.each{|order| @user_shipping_countries[order.customer_id] = order.customer.default_address.country_code}
    @user_shipping_states = {}
    orders.each{|order| @user_shipping_states[order.customer_id] = order.customer.default_address.province_code}
    @user_referring_sites = {}
    orders.each{|order| @user_referring_sites[order.customer_id] = order.referring_site}
    @user_landing_sites = {}
    orders.each{|order| @user_landing_sites[order.customer_id] = order.landing_site}
    @user_order_tags = {}
    orders.each{|order| @user_order_tags[order.customer_id] = order.tags}
    @user_discount_codes = {}
    orders.each{|order| @user_discount_codes[order.customer_id] = order.discount_codes.map{|item| item['code']} if order.discount_codes.class == Array}

    build_list(accepted_attrs, removed_attrs)
  end

  def build_list accepted_attrs, removed_attrs
    accepted_user_ids = {}
    removed_user_ids = []

    unless accepted_attrs.present?
      orders.pluck(:customer_id).each{|id| accepted_user_ids[id] = []}
    else
      accepted_attrs.as_json.each_with_index do |(k, v), i|
        ids = get_customer_ids(k, v["condition"], v["value"])
        ids.each do |id|
          accepted_user_ids[id] = Array.new(accepted_attrs.keys.size) unless accepted_user_ids[id].present?
          accepted_user_ids[id][i] = "X"
        end
      end
    end

    removed_attrs.as_json.each_with_index do |(k, v), i|
      removed_user_ids += get_customer_ids(k, v["condition"], v["value"])
    end if removed_attrs.present?
    removed_user_ids.each{|remove_id| accepted_user_ids.delete(remove_id)}
    Customer.includes(:orders, :postcards, :addresses).find(accepted_user_ids.keys).each do |customer|
      get_customer_detail(customer).each{|item| accepted_user_ids[customer.id].unshift(item)}
    end
    accepted_user_ids
  end

  def build_csv list, titles
    @csv = CustomersExportCsvService.new(list, titles).perform
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
    when "shipping_country"
      @user_shipping_countries
    when "shipping_state"
      @user_shipping_states
    when "referring_site"
      @user_referring_sites
    when "landing_site"
      @user_landing_sites
    when "order_tag"
      @user_order_tags
    when "discount_code_used"
      @user_discount_codes
    else
      []
    end
  end

  def filter_by collection, filter_type, raw_value
    collection.filter{|k,v| compare_field(v, filter_type, raw_value) if v}.keys
  end

  def match_filter? order, k, v
    field_to_filter = select_field_to_filter(k, order)
    compare_field(field_to_filter, v[:condition], v[:value])
  end

  def select_field_to_filter field, order
    orders = Order.where(customer_id: order.customer_id, shop_id: order.shop_id)
    case field
    when "number_of_order"
      orders.count
    when "total_spend"
      orders.sum(:total_line_items_price)
    when "last_order_date"
      orders.maximum(:processed_at)
    when "first_order_date"
      orders.minimum(:processed_at)
    when "last_order_total"
      orders.order(:processed_at).last.total_line_items_price
    when "order_total"
      order.total_price
    when "shipping_country"
      order.customer.default_address.country_code
    when "shipping_state"
      order.customer.default_address.province_code
    when "referring_site"
      order.landing_site
    when "discount_code"
      order.discount_codes.map{|item| item['code']} if order.discount_codes.class == Array
    when "tag"
      order.tags
    else
      []
    end
  end

  def calculate_compare_number_field field
    case field.class.to_s
    when ActiveSupport::TimeWithZone.to_s
      (field.to_date - Date.current).to_i.abs
    else
      field.to_i
    end
  end

  def compare_field field, condition, value
    case condition
      when "before"
        field.to_time < value.to_time.end_of_day
      when "between_date"
        splited_value = value.split("&")
        begin_value = splited_value[0].to_time.beginning_of_day
        end_value = splited_value[1].to_time.end_of_day
        (field.to_time > begin_value) && (field.to_time < end_value)
      when "after"
        field.to_time > value.to_time.beginning_of_day
      when "matches_number"
        calculate_compare_number_field(field) == value.to_i
      when "between_number"
        splited_value = value.split("&")
        begin_value = splited_value[0].to_i
        end_value = splited_value[1].to_i
        calculated_field = calculate_compare_number_field(field)
        (calculated_field >= begin_value) && (calculated_field <= end_value)
      when "matches_string"
        field.to_s == value.to_s
      when "1"
        field.to_i > value.to_i
      when "2"
        field.to_i < value.to_i
      when "8"
        field.to_time < Time.now.end_of_day - value.to_i.days
      when "9"
        field == value
      when "find_value"
        field.index(value)
      else
        false
    end
  end

  def get_customer_detail customer
    customer_detail = customer.default_address
    customer_order = Order.where(customer_id: customer.id).last
    customer_first_order = Order.where(customer_id: customer.id).first
    [ customer.full_name,
      customer.email,
      customer_detail.company,
      customer_detail.address1,
      customer_detail.city,
      customer_detail.province,
      customer_detail.country,
      customer_detail.zip,
      customer_detail.phone,
      customer_detail.company,
      customer_detail.address1,
      customer_detail.city,
      customer_detail.province,
      customer_detail.country,
      customer_detail.zip,
      customer_detail.phone,
      customer.orders_count,
      customer.total_spent,
      customer_order.processed_at,
      customer_order.fulfillment_status,
      customer_order.total_price,
      customer_first_order.processed_at,
      customer.postcards.count,
      customer.postcards.last&.date_sent,
      customer.accepts_marketing,
      customer.verified_email ? "Email verified" : "Not verified"
    ].reverse
  end

  def user_orders_count
    orders.group(:customer_id).count
  end

  def user_total_spents
    orders.group(:customer_id).sum(:total_line_items_price)
  end

  def user_last_orders
    orders.group(:customer_id).maximum(:processed_at)
  end

  def user_first_orders
    orders.group(:customer_id).minimum(:processed_at)
  end

  def user_last_order_totals
    res = {}
    orders.filter do |order|
      processed_time = user_last_orders[order.customer_id]
      processed_time.present? && processed_time == order.processed_at
    end.each{|i| res[i.customer_id] = i.total_line_items_price}
    res
  end

  def user_shipping_countries
    res = {}
    orders.each{|order| res[order.customer_id] = order.customer.default_address.country_code}
    res
  end

  def user_shipping_states
    res = {}
    orders.each{|order| res[order.customer_id] = order.customer.default_address.province_code}
    res
  end

  def user_referring_sites
    res = {}
    orders.each{|order| res[order.customer_id] = order.referring_site}
    res
  end

  def user_landing_sites
    res = {}
    orders.each{|order| res[order.customer_id] = order.landing_site}
    res
  end

  def user_order_tags
    res = {}
    orders.each{|order| res[order.customer_id] = order.tags}
    res
  end

  def user_discount_codes
    res = {}
    orders.each{|order| res[order.customer_id] = order.discount_codes.map{|item| item['code']} if order.discount_codes.class == Array}
    res
  end
end
