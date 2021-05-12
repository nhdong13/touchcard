class CustomerTargetingService
  attr_accessor :current_shop, :orders
  def initialize(shop=nil)
    if shop
      @current_shop = shop
      @orders = @current_shop.orders.where.not(customer_id: nil)
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
    orders.each{|order| @user_shipping_states[order.customer_id] = order.customer.default_address.province}
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
    # case filter_type
    #   when "0"
    #     value = raw_value.to_i
    #     collection.filter{|k,v| v == value}.keys
    #   when "1"
    #     value = raw_value.to_i
    #     collection.filter{|k,v| v > value}.keys
    #   when "2"
    #     value = raw_value.to_i
    #     collection.filter{|k,v| v < value}.keys
    #   when "3"
    #     value = raw_value.to_time.end_of_day
    #     collection.filter{|k,v| v < value}.keys
    #   when "4"
    #     begin_value = raw_value[0].to_time.beginning_of_day
    #     end_value = raw_value[1].to_time.end_of_day
    #     collection.filter{|k,v| (v < begin_value) && (v > end_value)}.keys
    #   when "5"
    #     value = raw_value.to_time.beginning_of_day
    #     collection.filter{|k,v| v > value}.keys
    #   when "6"
    #     value = raw_value.to_i.days
    #     collection.filter{|k,v| v > Time.now.beginning_of_day - value}.keys
    #   when "7"
    #     begin_value = raw_value[0].to_i.days
    #     end_value = raw_value[1].to_i.days
    #     collection.filter{|k,v| (v > Time.now.beginning_of_day - begin_value) && (v < Time.now.end_of_day - end_value)}.keys
    #   when "8"
    #     value = raw_value.to_i.days
    #     collection.filter{|k,v| v < Time.now.end_of_day - value}.keys
    #   else []
    # end
  end

  def match_filter? order, filter
    split_filter = filter.split("#")
    field_to_filter = select_field_to_filter(split_filter[0], order)
    compare_field(field_to_filter, split_filter[1], split_filter[2])
  end

  def select_field_to_filter field, order
    orders = Order.where(customer_id: order.customer_id, shop_id: order.shop_id)
    case field
    when "number_of_order"
      # order.customer.orders_count
      orders.count
    when "total_spend"
      # order.customer.total_spent
      orders.sum(:total_line_items_price)
    when "last_order_date"
      # order.customer.last_order_date
      orders.maximum(:processed_at)
    when "first_order_date"
      # order.customer.orders.order(created_at: :asc).first.created_at.to_date
      orders.minimum(:processed_at)
    when "last_order_total"
      # order.customer.orders.order(created_at: :desc).first.total_line_items_price
      orders.order(:processed_at).last.total_line_items_price
    when "order_total"
      order.total_price
    when "shipping_country"
      order.customer.default_address.country_code
    when "shipping_state"
      order.customer.default_address.province
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

  def compare_field field, condition, value
    case condition
      when "0"
        field.to_i == value.to_i
      when "1"
        field.to_i > value.to_i
      when "2"
        field.to_i < value.to_i
      when "3"
        field.to_time < value.to_time.end_of_day
      when "4"
        splited_value = value.split("&")
        begin_value = splited_value[0].to_time.beginning_of_day
        end_value = splited_value[1].to_time.end_of_day
        (field.to_time > begin_value) && (field.to_time < end_value)
      when "5"
        field.to_time > value.to_time.beginning_of_day
      when "6"
        field.to_time > Time.now.beginning_of_day - value.to_i.days
      when "7"
        splited_value = value.split("&")
        begin_value = splited_value[0].to_i.days
        end_value = splited_value[1].to_i.days
        (field.to_time < Time.now.end_of_day - begin_value) && (field.to_time > Time.now.beginning_of_day - end_value)
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
end
