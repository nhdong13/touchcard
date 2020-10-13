class DiscountManager
  attr_accessor :discount_code, :price_rule_id
  attr_reader :path, :value, :expire_at

  VALID_CODE_FORMAT = /[A-Z]{3}-[A-Z]{3}-[A-Z]{3}/

  def initialize(path, value, expire_at, extra_rules= {})
    raise "Missing required values for creating price rule" unless value and expire_at
    @discount_code = generate_code
    @path = path
    @value = value
    @expire_at = expire_at
    @extra_rules = extra_rules || {}
  end

  def generate_discount
    create_price_rule
    create_discount_code
  end

  def create_discount_code
    response = HTTParty.post(discount_url,
      body: {
        discount_code: {
          code: discount_code
        }
      })
    handle_discount_response(response)
  end

  def create_price_rule

    price_rule_data =  {
        title: "#{discount_code}",
        target_type: "line_item",
        target_selection: "all",
        allocation_method: "across",
        value_type: "percentage",
        value: value,
        once_per_customer: false,
        usage_limit: 1,
        customer_selection: "all",
        starts_at: Time.now,
        ends_at: expire_at
    }
    price_rule_data.merge!(@extra_rules) if @extra_rules

    response = HTTParty.post(price_rule_url,
      body: {
        price_rule: price_rule_data
      })
    handle_price_rule_response(response)
  end

  def discount_url
    url = path + "/price_rules/#{price_rule_id}/discount_codes.json"
  end

  def price_rule_url
    url = path + "/price_rules.json"
  end

  def handle_discount_response(response)
    Rails.logger.info response.body
    raise "Error registering discount code" unless response.success?
    @discount_code = response.parsed_response["discount_code"]["code"]
  end

  def handle_price_rule_response(response)
    Rails.logger.info response.body
    raise "Error registering for_price_rule" unless response.success?
    @price_rule_id = response.parsed_response["price_rule"]["id"]
  end

  def has_valid_code?
    !!(VALID_CODE_FORMAT =~ discount_code)
  end

  private

  def generate_code
    code = ("A".."Z").to_a.sample(9).join
    "#{code[0...3]}-#{code[3...6]}-#{code[6...9]}"
  end
end
