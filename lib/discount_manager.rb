class DiscountManager
  attr_reader :code, :shopify_api_path

  def initialize(shopify_api_path)
    @code = generate_code
    @shopify_api_path = shopify_api_path
  end

  def create_discount(price_rule_id)
    url = shopify_api_path + "/price_rules/#{price_rule_id}/discount_codes.json"

    discount_code = HTTParty.post(url,
      body: {
        discount_code: {
          code: code
        }
      })

    Rails.logger.info discount_code.body
    raise "Error registering discount code" unless discount_code.success?
    code
  end

  def create_price_rule(percent, expiration)
    url = shopify_api_path + "/price_rules.json"

    response = HTTParty.post(url,
      body: {
        price_rule: {
          title: "#{code}",
          target_type: "line_item",
          target_selection: "all",
          allocation_method: "each",
          value_type: "percentage",
          value: percent,
          once_per_customer: true,
          customer_selection: "all",
          starts_at: Time.now,
          ends_at: expiration
        }
      })

    Rails.logger.info response.body
    raise "Error registering price rule" unless response.success?

    response.parsed_response["price_rule"]
  end

  private

  def generate_code
    code = ("A".."Z").to_a.sample(9).join
    "#{code[0...3]}-#{code[3...6]}-#{code[6...9]}"
  end
end
