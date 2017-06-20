class DiscountManager
  attr_writer :code, :price_rule_id
  attr_reader :shopify_api_path
  
  def initialize(path, value, expire_at)
    raise "Missing required values for creating price rule" unless value and expire_at
    @code = generate_code
    @path = path
    @value = value
    @expire_at = expire_at
  end

  def create
    create_price_rule
    create_discount
  end

  def create_discount
    response = HTTParty.post(discount_url,
      body: {
        discount_code: {
          code: code
        }
      })
    handle_response(response, false)
  end

  def create_price_rule
    response = HTTParty.post(price_rule_url,
      body: {
        price_rule: {
          title: "#{code}",
          target_type: "line_item",
          target_selection: "all",
          allocation_method: "each",
          value_type: "percentage",
          value: value,
          once_per_customer: true,
          customer_selection: "all",
          starts_at: Time.now,
          ends_at: expire_at
        }
      })
    handle_response(response)
  end

  def discount_url
    url = path + "/price_rules/#{price_rule_id}/discount_codes.json"
  end

  def price_rule_url
    url = path + "/price_rules.json"
  end

  def handle_response(response, for_price_rule=true)
    Rails.logger.info response.body
    raise "Error registering #{for_price_rule ? "price rule" : "discount code"}" unless response.success?
    if for_price_rule?
      @price_rule_id = response.parsed_response["price_rule"]["id"]
    else
      @code = response.parsed_response["discount_code"]["code"]
    end
  end

  private

  def generate_code
    code = ("A".."Z").to_a.sample(9).join
    "#{code[0...3]}-#{code[3...6]}-#{code[6...9]}"
  end
end
