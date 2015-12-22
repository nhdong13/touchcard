# Include S3 utilities
require "aws_utils"
require "card_html"

class Postcard < ActiveRecord::Base
  belongs_to :card_order
  belongs_to :order
  belongs_to :customer
  has_one :shop, through: :card_order
  has_many :orders

  # TODO add this validation back
  validates :card_order, presence: true

  def revenue
    orders.sum(:total_price)
  end

  def address
    customer.default_address
  end

  def to_address
    address.to_lob_address
  end

  def generate_discount_code
    code = ("A".."Z").to_a.sample(9).join
    code = "#{code[0...3]}-#{code[3...6]}-#{code[6...9]}"
    card_order.shop.new_discount(card_order, code)
    code
  end

  def self.send_all
    Postcard.where("paid = TRUE AND sent = FALSE AND send_date <= ?", Time.now)
      .each(&:send_card)
  end

  def pay
    # TODO make sure this is atomic
    return logger.info "already paid for postcard:#{id}" if paid?
    return logger.info "not enough credits postcard:#{id}" unless can_afford?
    shop.credit -= cost
    shop.save!
    self.paid = true
    self
  end

  def can_afford?
    shop.credit >= cost
  end

  def cost
    address.country_code == "US" ? 1 : 2
  end

  def send_card
    return logger.info "sending postcard:#{id} that is not paid for" unless paid?
    # TODO: all kinds of error handling
    # Test lob
    @lob = Lob.load
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
        discount_exp: card_order.expiration_date,
        discount_code: card_side.show_discount? ? nil : discount_code
      )
    end

    sent_card = @lob.postcards.create(
      description: "A #{card_order.type} card sent by #{shop.domain}",
      to: to_address,
      # from: shop_address, # Return address for Shop
      front: front_html,
      back: back_html
    )
    self.sent = true
    self.postcard_id = sent_card["id"]
    self.date_sent = Date.today
    self.save! # TODO: Add error handling here
  end
end
