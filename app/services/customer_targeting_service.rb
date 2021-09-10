class CustomerTargetingService
  attr_accessor :orders, :current_shop, :accepted_attrs, :removed_attrs
  ACTIVE_FILTERS = ["last_order_date",
                    "first_order_date",
                    "last_order_tag",
                    "any_order_tag",
                    "last_discount_code",
                    "any_discount_code",
                    "last_order_total",
                    "discount_amount"
                  ]
  def initialize(params, accepted_attrs, removed_attrs)
    @current_shop = params[:shop] ? params[:shop] : params[:order].shop
    @orders = params[:order] ? [params[:order]] : get_orders_in_campaign
    @accepted_attrs = finalize_atrrs(accepted_attrs)
    @removed_attrs = finalize_atrrs(removed_attrs)
  end

  def finalize_atrrs attrs
    attrs&.select{|k,v|!(v["condition"] == "between_number" && v["value"] == "&")}&.each&.with_index do |(k, v), index|
      if v["condition"] == "between_number"
        splited_value = v["value"].to_s.split("&")
        if splited_value.empty?
          attrs.delete_at(index)
        elsif splited_value[0] == ""
          v["condition"] = "smaller_number"
          v["value"] = splited_value[1]
        elsif splited_value[1].nil?
          v["condition"] = "greater_number"
          v["value"] = splited_value[0]
        end
      end
      if v["condition"] == "between_date"
        splited_value = v["value"].to_s.split("&")
        if splited_value.empty?
          attrs.delete_at(index)
        elsif splited_value[0] == ""
          v["condition"] = "before"
          v["value"] = splited_value[1]
        elsif splited_value[1].nil?
          v["condition"] = "after"
          v["value"] = splited_value[0]
        end
      end
    end
  end

  def build_csv list
    accepted_attrs_shorthand = []
    accepted_attrs&.each{|k, v| accepted_attrs_shorthand << shorthand(k, v)}
    @csv = CustomersExportService.new(list, accepted_attrs_shorthand).create_xlsx
  end

  def export_customer_list
    filtered_customer_ids = get_list_customer_ids
    customer_data = build_export_data(filtered_customer_ids)
    titles = accepted_attrs.present? ? ["customer_id"] + CSV_TITLE + accepted_attrs.keys : ["customer_id"] + CSV_TITLE
    build_csv(customer_data)
  end

  # Build export data
  def build_export_data customer_ids
    response = []
    customer_ids.each do |id|
      response.push(customer_line_data(Customer.find(id)))
      Order.where(customer_id: id, shop_id: current_shop.id)&.each do |order|
        response.push(order_line_data(order))
        order.line_items&.each do |item|
          response.push(item_line_data(item))
        end
      end
    end
    # customer_ids.each do |id|
    #   mark_passed_filters = Array.new(accepted_attrs&.keys.size).insert(0, id)
    #   accepted_attrs&.each.with_index(1) do |(k, v), index|
    #     field_to_filter = select_field_to_filter(k, nil, id)
    #     mark_passed_filters[index] = "X" if compare_field(field_to_filter, v["condition"], v["value"])
    #   end
    #   mark_passed_filters.insert(1, get_customer_detail(Customer.find(id))).flatten!
    #   response.push(mark_passed_filters)
    # end
    response
  end

  def customer_line_data customer
    [ customer.id, "Customer", customer.first_name, customer.last_name,
      customer.default_address&.address1, customer.default_address&.city,
      customer.default_address&.province_code, customer.default_address&.country_code,
      customer.default_address&.zip, customer.default_address&.company, "", "", "", "", "", "",
      customer.orders.where(shop_id: current_shop.id).count, "",
      currency_formater(Order.where(customer_id: customer.id, shop_id: current_shop.id).sum(:total_line_items_price)),
      customer.tags, "", "", "", "", customer.postcards.count, customer.postcards.last&.date_sent&.strftime("%d-%b-%y"),
      customer.accepts_marketing ? "Y" : "N", "", "", ""
    ] + filter_passed_by_customer(customer.id)
  end

  def filter_passed_by_customer customer_id
    filters_passed_render = []
    accepted_attrs&.as_json&.each do |k, v|
      if ["shipping_country", "shipping_state", "shipping_city", "shipping_company", "number_of_order", "zip_code", "all_order_total"].include?(k)
        field_to_filter = select_field_to_filter(k, nil, customer_id)
        result = compare_field(field_to_filter, v["condition"], v["value"]) ? "X" : ""
      else
        result = ""
      end
      filters_passed_render << result
    end
    filters_passed_render
  end

  def order_line_data order
    [ order.customer&.id, "Order", order.customer&.first_name, order.customer&.last_name,
      order.customer&.default_address&.address1, order.customer&.default_address&.city,
      order.customer&.default_address&.province_code, order.customer&.default_address&.country_code,
      order.customer&.default_address&.zip, order.customer&.default_address&.company, "", order.id,
      order.processed_at&.strftime("%b %d, %Y"), "", "", "", "", order.line_items&.count, currency_formater(order.total_line_items_price),
      order.tags, order.referring_site, order.landing_site, order.discount_codes.map{|code| code['code']}.join(", "),
      currency_formater(order.total_discounts), "", "", "", order.financial_status, order.fulfillment_status, ""
    ] + filter_passed_by_order(order)
  end

  def filter_passed_by_order order
    filters_passed_render = []
    accepted_attrs&.as_json&.each do |k, v|
      if ACTIVE_FILTERS.include?(k)
        if (k.include?("last") && !is_last_order?(order)) || (k.include?("first") && !is_first_order?(order))
          result = ""
        else
          filter = k.gsub("any", "last")
          field_to_filter = select_field_to_filter(filter, order)
          result = compare_field(field_to_filter, v["condition"], v["value"]) ? "X" : ""
        end
      else
        result = ""
      end
      filters_passed_render << result
    end
    filters_passed_render
  end

  def is_last_order? order
    Order.where(customer_id: order.customer_id, shop_id: current_shop.id).last == order
  end

  def is_first_order? order
    Order.where(customer_id: order.customer_id, shop_id: current_shop.id).first == order
  end

  def item_line_data item
    [ item.order&.customer&.id, "Order Item", "", "", "", "", "", "", "", "", "",
      item.order&.id, item.order&.processed_at&.strftime("%b %d, %Y"), item.title, item.sku,
      item.variant_title, "", item.quantity, currency_formater(item.price.to_f * 100),
      "", "", "", "", "", "", "", "", "", "", ""
    ] + Array.new(accepted_attrs&.keys&.length, "")
  end
  # End build export data section

  def get_list_customer_ids
    all_customer_ids = current_shop.orders.where.not(customer_id: nil).pluck(:customer_id).uniq
    fit_customer_ids = all_customer_ids.filter{|id|
      customer_pass_filter?(id)
    }
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
    accepted_attrs.size == 0 ? true : false
  end

  def filtered_orders filter_order=nil
    orders_to_filter = filter_order.present? ? [filter_order] : orders
    orders_to_filter.select do |order|
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
      customer = Customer.find_by_id(filter_customer_id)
      user_orders = Order.where(customer_id: filter_customer_id, shop_id: current_shop.id)
    end
    filter_order = order || user_orders.last
    begin
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
      when "last_order_tag"
        filter_order.tags&.split(", ")
      when "any_order_tag"
        user_orders.map{|order| order.tags&.split(', ')}.flatten
      when "last_discount_code"
        filter_order.discount_codes.map{|item| item['code']} if filter_order.discount_codes.class == Array
      when "any_discount_code"
        user_orders.map{|order| order.discount_codes.map{|item| item['code']} if order.discount_codes.class == Array}.select{|order|order.class == Array}.flatten
      when "last_order_total"
        filter_order.total_price.to_f / 100
      when "all_order_total"
        user_orders.sum(:total_price).to_f / 100
      when "discount_amount"
        filter_order.discount_codes
      # end
      # ongoing
      # end
      when "referring_site"
        filter_order.referring_site
      when "landing_site"
        filter_order.landing_site
      when "shipping_company"
        customer&.default_address.company
      when "zip_code"
        customer&.default_address.zip
      else
        []
      end
    rescue StandardError => e
      # If there is an error such as nil order
      # This rescue is to log the error and keep the system going
      Rails.logger.debug "[ERROR] #{e.class} #{e.message}"
      nil
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
    begin
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
        when "smaller_number"
          calculate_compare_number_field(field) <= value.to_i
        when "greater_number"
          calculate_compare_number_field(field) >= value.to_i
        when "between_number"
          splited_value = value.split("&")
          begin_value = splited_value[0].to_i
          end_value = splited_value[1].to_i
          calculated_field = calculate_compare_number_field(field)
          (calculated_field >= begin_value) && (calculated_field <= end_value)
        when "matches_string"
          field.to_s.casecmp?(value.to_s)
        when "contain_string"
          field.to_s.upcase.include?(value.to_s.upcase)
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
        # This is for filter shipping company
        when "no"
          field.blank?
        when "yes"
          !field.blank?
        # This is for filter zip code
        when "equal"
          field == value
        when "begin_with"
          field&.start_with?(value)
        when "end_with"
          field&.end_with?(value)
        when "discount_amount_between"
          return false if field.class != Array || !field[0].present?
          currency_type = value[0] == "%" ? "percentage" : "fixed_amount"
          splited_value = value[1..-1]
          value_1 = splited_value.split("&")[0].to_f
          value_2 = splited_value.split("&")[1].to_f

          field[0]["type"] == currency_type && field[0]["amount"].to_f >= value_1 && field[0]["amount"].to_f <= value_2
        when "discount_amount_matches"
          return false if field.class != Array || !field[0].present?
          currency_type = value[0] == "%" ? "percentage" : "fixed_amount"
          field[0]["type"] == currency_type && value[1..-1].to_f == field[0]["amount"].to_f
        else
          false
      end
    rescue StandardError => e
      # If there is an error such as nil order
      # This rescue is to log the error and keep the system going
      Rails.logger.debug "[ERROR] #{e.class} #{e.message}"
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

  def shorthand key, value
    shorthand = case key.to_s
    when "number_of_order"
      "ORD"
    when "last_order_date"
      "LST-ORD-DATE"
    when "first_order_date"
      "FST-ORD-DATE"
    when "last_order_total"
      "LST-ORD-TTL"
    when "all_order_total"
      "TTL-SPND"
    when "shipping_country"
      "COUNTRY"
    when "shipping_state"
      "STATE"
    when "shipping_city"
      "CITY"
    when "shipping_company"
      "COMPANY"
    when "customer_tag"
      "CUST-TAG"
    when "last_referring_site"
      "LST-REF-SITE"
    when "any_referring_site"
      "ANY-REF-SITE"
    when "last_landing_site"
      "LST-LND-SITE"
    when "any_landing_site"
      "ANY-LND-SITE"
    when "last_order_tag"
      "LST-ORD-TAG"
    when "any_order_tag"
      "ANY-ORD-TAG"
    when "last_product_name"
      "LST-PROD-NAME"
    when "any_product_name"
      "ANY-PROD-NAME"
    when "last_product_sku"
      "LST-PROD-SKU"
    when "any_product_sku"
      "ANY-PROD-SKU"
    when "last_product_collection"
      "LST-PROD-COLL"
    when "any_product_collection"
      "ANY-PROD-COLL"
    when "last_discount_code"
      "LST-DSCNT-CODE"
    when "any_discount_code"
      "ANY-DSCNT-CODE"
    when "discount_amount"
      "DSCNT"
    when "number_postcard_received"
      "PSTCRD"
    when "last_postcard_received"
      "LST-PSTCRD"
    when "accept_marketing"
      "MARKETING"
    when "last_financial_status"
      "LST-FIN-STS"
    when "any_financial_status"
      "ANY-FIN-STS"
    when "last_order_fulfillment_status"
      "LST-FUL-STS"
    when "any_order_fulfillment_status"
      "ANY-FUL-STS"
    else
      ""
    end
    shorthand += ": " + case value["condition"]
    when "before"
      "<" + value["value"].to_date.strftime("%b %d, %Y")
    when "after"
      ">" + value["value"].to_date.strftime("%b %d, %Y")
    when "between_date"
      date_1 = value["value"].split("&")[0].to_date.strftime("%b %d, %Y")
      date_2 = value["value"].split("&")[1].to_date.strftime("%b %d, %Y")
      date_1 + " - " + date_2
    when "matches_number"
      if key.include?("order_date")
        value["value"].to_s + " days"
      else
        value["value"].to_s
      end
    when "smaller_number"
      "<=" + value["value"].to_s
    when "greater_number"
      ">=" + value["value"].to_s
    when "between_number"
      value_1 = value["value"].split("&")[0]
      value_2 = value["value"].split("&")[1]
      if key.include?("order_date")
        value_1 + "-" + value_2 + " days"
      else
        value_1 + "-" + value_2
      end
    when "discount_amount_between"
      value["value"].to_s.sub("&", "-")
    when "discount_amount_matches"
      value["value"].to_s
    else
      ""
    end
  end

  def currency_formater value
    ActionController::Base.helpers.number_to_currency(value.to_f/100)
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
end
