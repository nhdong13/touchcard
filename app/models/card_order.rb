class CardOrder < ApplicationRecord
  TYPES = ['PostSaleOrder', 'CustomerWinbackOrder', 'LifetimePurchaseOrder', 'AbandonedCard']

  belongs_to :shop
  belongs_to :card_side_front, class_name: "CardSide",
              foreign_key: "card_side_front_id"
  belongs_to :card_side_back, class_name: "CardSide",
              foreign_key: "card_side_back_id"
  has_many :filters, dependent: :destroy
  has_many :postcards

  accepts_nested_attributes_for :card_side_front
  # , reject_if: :invalid_image_size
  accepts_nested_attributes_for :card_side_back
  # , reject_if: :invalid_image_size
  accepts_nested_attributes_for :filters,
    allow_destroy: true,
    reject_if: :all_blank

  validates :shop, :card_side_front, :card_side_back, presence: true

  before_update :convert_discount_pct, if: :discount_pct_changed?

  delegate :current_subscription, to: :shop

  def send_postcard?(order)
    return true unless filters.count > 0
    spend = order.total_price / 100.0
    filter = filters.first
    # if the filters are nil assume they're unbounded
    min = filter.filter_data["minimum"].to_f || -1.0
    max = filter.filter_data["maximum"].to_f.positive? ? filter.filter_data["maximum"].to_f : 1_000_000_000.0
    spend > min && spend < max
  end

  # number of postcards sent for current subscription
  def cards_sent
    return 0 unless current_subscription
    postcards
      .where("created_at > ?", current_subscription.current_period_start)
      .count
  end

  # total number of postcards sent
  def cards_sent_total
     postcards.where(sent: true).size
  end

  def revenue
    Order.joins(:postcards).where(postcards: { card_order_id: id })
      .sum(:total_price)
  end

  def ensure_defaults
    self.card_side_front ||= CardSide.create!(is_back: false)
    self.card_side_back ||= CardSide.create!(is_back: true)
  end

  def discount?
    !discount_exp.nil? && !discount_pct.nil?
  end

  def send_date
    return Date.today + send_delay.weeks
    # 4-6 business days delivery according to lob
    # TODO: handle international + 5 to 7 business days
    #send_date = arrive_by - 1.week
  end

  def prepare_for_sending(postcard_trigger)
    return logger.info "international customer not enabeled" if postcard_trigger.international && !international?
    return logger.info "international customer not enabeled" if postcard_trigger.international && !international?
    return logger.info "order filtered out" unless send_postcard?(postcard_trigger)

    postcard = postcard_trigger.postcards.new(
      card_order: self,
      customer: postcard_trigger.customer,
      send_date: self.send_date,
      paid: false)
    if shop.pay(postcard)
      postcard.paid = true
      postcard.save
    else
      logger.info postcard.errors.full_messages.map{|msg| msg}.join("\n")
      false
    end
  end

  def convert_discount_pct
    self.discount_pct = -discount_pct if discount_pct && discount_pct > 0
  end

  private

  def invalid_image_size(attributes)
    # debugger
  end
end
