class DiscountManager
  attr_accessor :discount_code, :price_rule_id
  attr_reader :path, :value, :expire_at

  def initialize(path, value, expire_at)
    raise "Missing required values for creating price rule" unless value and expire_at
    @discount_code = generate_code
    @path = path
    @value = value
    @expire_at = expire_at
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
    response = HTTParty.post(price_rule_url,
      body: {
        price_rule: {
          title: "#{discount_code}",
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
    (/[A-Z]{3}-[A-Z]{3}-[A-Z]{3}/).match(discount_code)
  end

  private

  def generate_code
    code = ("A".."Z").to_a.sample(9).join
    "#{code[0...3]}-#{code[3...6]}-#{code[6...9]}"
  end
end
