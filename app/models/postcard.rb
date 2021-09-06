require "aws_utils"
require "card_html"
require "newrelic_rpm"
require "discount_manager"
require "postcard_render_util"

class Postcard < ApplicationRecord
  belongs_to :card_order
  belongs_to :order, optional: true
  belongs_to :customer
  belongs_to :postcard_trigger, polymorphic: true # Use Postcard's card_order
  has_one :shop, through: :card_order
  has_many :orders

  validates :card_order, presence: true

  # TODO: Unused Automations Code
  #
  # validate :one_active_postcard_per_customer

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
    customer&.default_address
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
      .where("error IS NULL AND paid = TRUE AND sent = FALSE AND canceled = FALSE AND send_date <= ?
               AND shops.approval_state != ?", Time.now, "denied")
    todays_cards.each do |card|
      begin
        card.send_card
      rescue => e
        num_failed += 1
        # logger.error e
        # NewRelic::Agent::notice_error(e.message)
        card.error = e.message
        card.save
        ReportErrorMailer.send_error_report(card.card_order).deliver_later
        next
      end
    end
    {
      card_sent_amount: todays_cards.size - num_failed,
      total_card: todays_cards.size,
      error_cards_amount: num_failed
    }
  end

  def self.send_all_history_cards(shop)
    num_failed = 0
    shop.postcards
    cards = shop.postcards
      .where("paid = TRUE AND sent = FALSE AND canceled = FALSE AND data_source_status = ?", "history")
    cards.each do |card|
      begin
        return if card.postcard_trigger.international && !card.card_order.international?
        card.send_card
      rescue => e
        num_failed += 1
        logger.error e
        NewRelic::Agent::notice_error(e.message)
        next
      end
    end
    cards.size - num_failed
  end

  # 1 token = 0.89$
  # 2 tokens = 1.78$
  def cost
    begin
      international? ? 1.78 : 0.89
    rescue
      0
    end
  end

  class DiscountCreationError < StandardError
  end

  def prepare_card
    self.estimated_arrival = estimated_transit_days.business_days.from_now.end_of_day
    if card_order.has_discount?
      self.discount_pct = -(card_order.discount_pct.abs)
      self.discount_exp_at = Time.current.end_of_day + card_order.discount_exp.weeks + 7.days
      if (ENV['APP_URL'] == "https://touchcard-dev.herokuapp.com/") and (card_order.shop.domain != "stagecard.myshopify.com")
        self.discount_code = "SAM-PLE-XXX"
        return
      end
      @discount_manager = DiscountManager.new(card_order.shop.shopify_api_path, discount_pct, discount_exp_at + 1.day, card_order.price_rules)
      @discount_manager.generate_discount
      self.price_rule_id = @discount_manager.price_rule_id
      self.discount_code = @discount_manager.discount_code
      raise DiscountCreationError, "Error allocating discount code" unless @discount_manager.has_valid_code?
    end
  end


  def send_card
    return logger.info "attempted sending postcard:#{id} that is not paid for" unless paid?
    return logger.info "postcard:#{id} with lob_id:#{postcard_id} already sent" if postcard_id
    # TODO: all kinds of error handling

    prepare_card

    front_png_path = PostcardRenderUtil.render_side_png(postcard: self, is_front: true)
    back_png_path = PostcardRenderUtil.render_side_png(postcard: self, is_front: false)

    @lob ||= Lob::Client.new(api_key: ENV['LOB_API_KEY'], api_version: LOB_API_VER)
    sent_card = @lob.postcards.create(
      description: "#{card_order.type} #{shop.domain}",
      to: to_address,
      from: return_address,
      front:  File.new(front_png_path),
      back: File.new(back_png_path)
    )
    self.sent = true
    self.date_sent = Date.today
    self.postcard_id = sent_card["id"]
    self.save! # TODO: Add error handling here

    # Note: If `send_card` throws an exception (which it definitely can), this doesn't get cleaned up.
    # I don't want to mess with exception handling here because it affects the core sending logic.
    # It shouldn't be a common enough issue to make us run out of disk space (since it's run in scheduler anyway)

    File.delete(front_png_path) if File.exist?(front_png_path)
    File.delete(back_png_path) if File.exist?(back_png_path)
  end

  # TODO: Unused Automations Code
  #
  # def one_active_postcard_per_customer
  #   postcards = Postcard.where.not(
  #     id: self.id
  #   ).where(
  #     "customer_id = :customer_id AND estimated_arrival > :arrival AND canceled IS false",
  #     self_id: self.id,
  #     customer_id: customer_id,
  #     arrival: Time.now
  #   )
  #   if postcards.any?
  #     errors.add(:customer_id, "There is already one active card for this customer")
  #   end
  # end

  def cancel
    self.canceled = true
    self.transaction do
      self.shop.increment_credit if self.paid
      self.paid = false
    end
    self.save!
  end

  def return_address
    if card_order.international
      return_address = card_order.return_address
      return {} unless return_address
      {
        name: return_address.name[0...40],
        address_line1: return_address.address_line1,
        address_line2: return_address.address_line2,
        address_city: return_address.city,
        address_state: return_address.state,
        address_country: "US",
        address_zip: return_address.zip
      }
    else
      {}
    end
  end

  def city
    address&.city
  end

  def state
    address&.province
  end

  def country
    address&.country
  end

end
