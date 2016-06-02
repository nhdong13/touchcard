class CardOrder < ActiveRecord::Base
  belongs_to :shop
  belongs_to :card_side_front, class_name: "CardSide",
              foreign_key: "card_side_front_id"
  belongs_to :card_side_back, class_name: "CardSide",
              foreign_key: "card_side_back_id"
  has_many :filters
  has_many :postcards

  validates :shop, :card_side_front, :card_side_back, presence: true

  after_initialize :ensure_defaults

  def send_postcard?(order)
    return true unless filters.count > 0
    spend = order.total_line_items_price / 100.0
    filter = filters.first
    # if the filters are nil assume they're unbounded
    min = filter.filter_data["minimum"].to_f || -1.0
    # TODO: when we create campaigns we may want to reintroduce a maximum value here.
    spend > min
  end

  def cards_sent
    postcards.where(sent: true).count
  end

  def revenue
    Order.joins(:postcard).where(postcards: { card_order_id: id })
      .sum(:total_price)
  end

  def ensure_defaults
    self.card_side_front ||= CardSide.create!(is_back: false)
    self.card_side_back ||= CardSide.create!(is_back: true)
    self.send_delay = 0 if send_delay.nil? && type == "PostSaleOrder"
    self.international = false if international.nil?
    self.enabled = false if enabled.nil?
    # TODO: add defaults to schema that can be added
  end

  def discount?
    !discount_exp.nil? && !discount_pct.nil?
  end

  def send_date
    return Date.today + send_delay.weeks if type == "PostSaleOrder"
    # 4-6 business days delivery according to lob
    # TODO handle international + 5 to 7 business days
    send_date = arrive_by - 1.week
  end

  def prepare_for_sending(postcard_trigger)
    return if postcard_trigger.international && !international?
    return unless send_postcard?(postcard_trigger)
    postcard = postcard_trigger.postcards.new(
      card_order: self,
      customer: postcard_trigger.customer,
      paid: false)
    postcard.pay.save! if postcard.can_afford?
  end
end
