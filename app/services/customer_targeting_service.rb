class CustomerTargetingService
  attr_accessor :orders, :current_shop, :accepted_attrs, :removed_attrs
  def initialize(params, accepted_attrs, removed_attrs)
    @current_shop = params[:shop] ? params[:shop] : params[:order].shop_id
    @orders = params[:order] ? [params[:order]] : get_orders_in_campaign
    @accepted_attrs = accepted_attrs
    @removed_attrs = removed_attrs
  end

  def build_csv list, titles
    @csv = CustomersExportService.new(list, titles).perform
  end

  def export_customer_list
    filtered_customer_ids = get_list_customer_ids
    customer_data = build_export_data(filtered_customer_ids)
    titles = accepted_attrs.present? ? ["customer_id"] + CSV_TITLE + accepted_attrs.keys : ["customer_id"] + CSV_TITLE
    build_csv(customer_data, titles)
  end

  def build_export_data customer_ids
    response = []
    customer_ids.each do |id|
      mark_passed_filters = Array.new(accepted_attrs&.keys.size).insert(0, id)
      accepted_attrs&.each.with_index(1) do |(k, v), index|
        field_to_filter = select_field_to_filter(k, nil, id)
        mark_passed_filters[index] = "X" if compare_field(field_to_filter, v["condition"], v["value"])
      end
      mark_passed_filters.insert(1, get_customer_detail(Customer.find(id))).flatten!
      response.push(mark_passed_filters)
    end
    response
  end

  def get_list_customer_ids
    all_customer_ids = current_shop.orders.where.not(customer_id: nil).pluck(:customer_id).uniq
    fit_customer_ids = all_customer_ids.filter{|id| customer_pass_filter?(id)}
  end

  def customer_pass_filter? customer_id
    removed_attrs&.each do |k, v|
      field_to_filter = select_field_to_filter(k, nil, customer_id)
      return false if compare_field(field_to_filter, v["condition"], v["value"])
    end
    accepted_attrs&.each do |k, v|
      field_to_filter = select_field_to_filter(k, nil, customer_id)
      return true if compare_field(field_to_filter, v["condition"], v["value"])
    end
    true
  end

  def filtered_orders
    orders.select do |order|
      result = true
      accepted_attrs.as_json&.each do |k, v|
        field_to_filter = select_field_to_filter(k, order)
        result = result && compare_field(field_to_filter, v["condition"], v["value"])
      end
      removed_attrs.as_json&.each do |k, v|
        field_to_filter = select_field_to_filter(k, order)
        result = result && !compare_field(field_to_filter, v["condition"], v["value"])
      end
      result
    end
  end

  # Filter service
  def match_filter?
    filtered_orders.present?
  end

  def select_field_to_filter field, order=nil, customer_id=nil
    filter_customer_id = customer_id || order.customer&.id
    if filter_customer_id
      customer = Customer.find_by(filter_customer_id)
      user_orders = Order.where(customer_id: filter_customer_id, shop_id: current_shop.id)
    end
    filter_order = order || user_orders.last

    case field.to_s
    # completed
    when "last_order_date"
      filter_order.processed_at
    when "first_order_date"
      user_orders.minimum(:processed_at)
    when "number_of_order"
      user_orders.count
    when "shipping_country"
      customer&.default_address.country_code
    when "shipping_state"
      customer&.default_address.province_code
    when "shipping_city"
      customer&.default_address.city
    # end
    # ongoing
    when "last_order_tag"
      filter_order.tags.split(", ")
    when "any_order_tag"
      user_orders.map{|order| order.tags&.split(', ')}.flatten
    when "last_discount_code"
      filter_order.discount_codes.map{|item| item['code']}
    when "any_discount_code"
      user_orders.map{|order| order.discount_codes.map{|item| item['code']}}.select{|order|order.class == Array}.flatten
    # end
    when "total_spend"
      user_orders.sum(:total_line_items_price)
    when "last_order_total"
      user_orders.order(:processed_at).last.total_line_items_price
    when "order_total"
      filter_order.total_price
    when "referring_site"
      filter_order.landing_site
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
        field.to_time < value.to_time.beginning_of_day
      when "between_date"
        splited_value = value.split("&")
        begin_value = splited_value[0].to_time.beginning_of_day
        end_value = splited_value[1].to_time.end_of_day
        (field.to_time > begin_value) && (field.to_time < end_value)
      when "after"
        field.to_time > value.to_time.end_of_day
      when "matches_number"
        calculate_compare_number_field(field) == value.to_i
      when "between_number"
        splited_value = value.split("&")
        begin_value = splited_value[0].to_i
        end_value = splited_value[1].to_i
        calculated_field = calculate_compare_number_field(field)
        (calculated_field >= begin_value) && (calculated_field <= end_value)
      when "matches_string"
        field.to_s.casecmp?(value.to_s)
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
      when "from"
        value.join(",").index(field).present?
      when "tag_is"
        value.each{|item| return false unless field.include?(item)}
        true
      when "tag_contain"
        value.each{|item| return true if field.include?(item)}
        false
      else
        false
    end
  end

  def get_orders_in_campaign
    current_shop.orders.where.not(customer_id: nil)
    # .joins(:postcard).where.not(customer_id: nil)
    #   .where(
    #     "paid = TRUE AND sent = FALSE AND canceled = FALSE AND send_date <= ? AND send_date >= ?",
    #     Time.now, Time.now - 2.weeks
    #   )
  end

  # get customer field for csv export
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
    ]
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
    orders.each{|order| res[order.customer_id] = order.customer&.default_address.country_code}
    res
  end

  def user_shipping_states
    res = {}
    orders.each{|order| res[order.customer_id] = order.customer&.default_address.province_code}
    res
  end

  def user_shipping_cities
    res = {}
    orders.each{|order| res[order.customer_id] = order.customer&.default_address.city}
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

  def user_order_tag
    res = {}
    orders.each{|order| res[order.customer_id] = order.tags}
    res
  end

  def user_discount_codes
    res = {}
    orders.each{|order| res[order.customer_id] = order.discount_codes.map{|item| item['code']} if order.discount_codes.class == Array}
    res
  end

  # Remove soon
  # export csv service
  def find
    @user_orders_count = orders.group(:customer_id).count
    @user_spends_count = orders.group(:customer_id).sum(:total_line_items_price)
    @user_last_order_totals = {}
    orders.filter do |order|
      processed_time = user_last_orders[order.customer_id]
      processed_time.present? && processed_time == order.processed_at
    end.each{|i| @user_last_order_totals[i.customer_id] = i.total_line_items_price}
    @user_referring_sites = {}
    orders.each{|order| @user_referring_sites[order.customer_id] = order.referring_site}
    @user_landing_sites = {}
    orders.each{|order| @user_landing_sites[order.customer_id] = order.landing_site}
    @user_discount_codes = {}
    orders.each{|order| @user_discount_codes[order.customer_id] = order.discount_codes.map{|item| item['code']} if order.discount_codes.class == Array}

    build_list
  end

  def build_list
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

  def get_customer_ids filter, condition, value
    collection = select_collection(filter)
    filter_by(collection, condition, value)
  end

  def select_collection filter
    case filter
    # completed
    when "last_order_date"
      user_last_orders
    when "first_order_date"
      user_first_orders
    when "number_of_order"
      user_orders_count
    when "shipping_country"
      user_shipping_countries
    when "shipping_state"
      user_shipping_states
    when "shipping_city"
      user_shipping_cities
    # end
    when "total_spend"
      @user_spends_count
    when "last_order_total"
      @user_last_order_totals
    when "referring_site"
      @user_referring_sites
    when "landing_site"
      @user_landing_sites
    # when "any_order_tag"
    #   user_order_tag
    # when "last_order_tag"
    #   user_order_tag
    # when "discount_code_used"
    #   user_discount_codes
    else
      []
    end
  end

  def filter_by collection, filter_type, raw_value
    collection.filter{|k,v| compare_field(v, filter_type, raw_value) if v}.keys
  end
end
