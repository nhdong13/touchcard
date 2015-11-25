# Include S3 utilities
require "aws_utils"
require "card_html"

class Postcard < ActiveRecord::Base
  belongs_to :card_order
  has_one :shop, through: :card_order

  validates :card_order, presence: true

  def self.create_postcard!(card_order, shopify_customer, triggering_shopify_order_id)
    Postcard.create!(
      triggering_shopify_order_id: triggering_shopify_order_id,
      card_order: card_order,
      shopify_customer_id: shopify_customer.id,
      customer_name: "#{shopify_customer.first_name} #{shopify_customer.last_name}",
      addr1: shopify_customer.default_address.address1,
      addr2: shopify_customer.default_address.address2,
      city: shopify_customer.default_address.city,
      state: shopify_customer.default_address.province_code,
      country: shopify_customer.default_address.country_code,
      zip: shopify_customer.default_address.zip,
      send_date: card_order.send_date
    )
  end

  def to_address
    {
      name: customer_name,
      address_line1: addr1,
      address_line2: addr2,
      address_city: city,
      address_state: state,
      address_country: country,
      address_zip: zip
    }
  end

  def generate_discount_code
    code = ("A".."Z").to_a.sample(9).join
    "#{code[0...3]}-#{code[3...6]}-#{code[6...9]}"
    card_order.shop.new_discount(code)
    code
  end

  def self.send_all
    Postcard.where("sent = ? and send_date <= ?", false, Time.now)
      .each(&:send_card)
  end

  def send_card
    # TODO: all kinds of error handling
    # Test lob
    @lob = Lob.load(api_key: ENV["LOB_TEST_API_KEY"])

    if (country == "US" && shop.credit >= 1) || shop.credit >= 2
      self.discount_code = generate_discount_code if card_order.discount?
      front_html, back_html = [
        card_order.card_side_front,
        card_order.card_side_back
      ].map do |card_side|
        CardHtml.generate(
          background_image: card_side.image,
          discount_x: card_side.discount_x,
          discount_y: card_side.discount_y,
          discount_pct: card_order.discount_pct,
          discount_exp: card_order.discount_exp,
          discount_code: discount_code
        )
      end

      sent_card = @lob.postcards.create(
        description: "A #{template} card sent by #{shop.domain}",
        to: to_address,
        # from: shop_address, # Return address for Shop
        front: front_html,
        back: back_html
      )
      self.sent = true
      self.postcard_id = sent_card["id"]
      self.date_sent = Date.today
      save # TODO: Add error handling here

      # Deduct 1 credit for US, 2 for international
      cost = country == "US" ? 1 : 2
      shop.credits -= cost
      shop.save
    else
      puts "No credits left on shop #{shop.domain}"
      # TODO: possibly delete the card and S3 files here
    end
  end
end
