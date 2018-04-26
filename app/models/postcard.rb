require "aws_utils"
require "card_html"
require "newrelic_rpm"
require "discount_manager"
require "lob_render_util"

class Postcard < ApplicationRecord
  belongs_to :card_order
  belongs_to :order
  belongs_to :customer
  belongs_to :postcard_triggerable, polymorphic: true
  has_one :shop, through: :card_order
  has_many :orders

  validates :card_order, presence: true

  validate :one_active_postcard_per_customer

  # get all postcards whom estimated_arrival is more than 3 days ago
  # and for which arrival notification is not sent
  def self.ready_for_arrival_notification
    three_days_ago = Time.now - 3.days
    where("arrival_notification_sent = false AND estimated_arrival < :three_days",
          three_days: three_days_ago)
    .includes(card_order: :shop)
    .includes(:customer)
  end

  def address
    customer.default_address
  end

  def international?
    address.country_code != "US"
  end

  def estimated_transit_days
    international? ? 15 : 6
    # Lob.com estimates 4-6 domestic and 5-7 extra for international. In reality we've seen
    # international cards take longer. Since coupon expiry is based on this figure, I've added
    # a few days to reduce the chance of expired coupons arriving
  end

  def to_address
    address.to_lob_address
  end

  def self.send_all
    num_failed = 0
    todays_cards = Postcard.joins(:shop)
      .where("paid = TRUE AND sent = FALSE AND canceled = FALSE AND send_date <= ?
              AND shops.approval_state != ?", Time.now, "denied")
    todays_cards.each do |card|
      begin
        card.send_card
      rescue => e
        num_failed += 1
        logger.error e
        NewRelic::Agent::notice_error(e.message)
        next
      end
    end
    todays_cards.size - num_failed
  end

  def cost
    international? ? 2 : 1
  end

  def send_card
    return logger.info "attempted sending postcard:#{id} that is not paid for" unless paid?
    return logger.info "postcard:#{id} with lob_id:#{postcard_id} already sent" if postcard_id
    # TODO: all kinds of error handling
    # Test lob
    @lob ||= Lob::Client.new(api_key: ENV['LOB_API_KEY'])
    self.estimated_arrival = estimated_transit_days.business_days.from_now.end_of_day

    if card_order.has_discount?
      self.discount_pct = -(card_order.discount_pct.abs)
      self.discount_exp_at = estimated_arrival + card_order.discount_exp.weeks
      @discount_manager = DiscountManager.new(card_order.shop.shopify_api_path, discount_pct, discount_exp_at)
      @discount_manager.generate_discount
      self.price_rule_id = @discount_manager.price_rule_id
      self.discount_code = @discount_manager.discount_code
      return unless @discount_manager.has_valid_code?
    end

    front_png_path, back_png_path = [
        card_order.card_side_front,
        card_order.card_side_back
    ].map do |card_side|
      input_html = LobApiController.render(:card_side,
                              assigns: {
                                  postcard: self,
                                  card_side: card_side,
                                  lob_js_pack_path: LobRenderUtil.lob_js_pack_path,
                                  lob_css_pack_path: LobRenderUtil.lob_css_pack_path })
      LobRenderUtil.headless_render(input_html)
    end

    # front_html, back_html = [
    #   card_order.card_side_front,
    #   card_order.card_side_back
    # ].map do |card_side|
    #   CardHtml.generate(
    #     background_image: card_side.image,
    #     discount_x: card_side.discount_x,
    #     discount_y: card_side.discount_y,
    #     discount_pct: discount_pct ? discount_pct.abs : nil,
    #     # Make customer think coupon expires a day early to avoid last minute disappoint for e.g. timezone issues
    #     discount_exp: discount_exp_at ? (discount_exp_at - 1.day).strftime("%m/%d/%Y") : nil,
    #     discount_code: card_side.show_discount? ? discount_code : nil
    #   )
    # end

    sent_card = @lob.postcards.create(
      description: "A #{card_order.type} card sent by #{shop.domain}",
      to: to_address,
      # from: shop_address, # Return address for Shop
      front:  File.new(front_png_path),
      back: File.new(back_png_path)
    )
    self.sent = true
    self.date_sent = Date.today
    self.postcard_id = sent_card["id"]
    self.save! # TODO: Add error handling here
  end

  def one_active_postcard_per_customer
    postcards = Postcard.where.not(
      id: self.id
    ).where(
      "customer_id = :customer_id AND estimated_arrival > :arrival AND canceled IS false",
      self_id: self.id,
      customer_id: customer_id,
      arrival: Time.now
    )
    if postcards.any?
      errors.add(:customer_id, "There is already one active card for this customer")
    end
  end

  def cancel
    self.canceled = true
    self.transaction do
      self.shop.increment_credit if self.paid
      self.paid = false
    end
    self.save!
  end

  def city
    address.city
  end

  def state
    address.province
  end

  def country
    address.country
  end
end
