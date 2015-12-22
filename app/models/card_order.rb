class CardOrder < ActiveRecord::Base
  belongs_to :shop
  belongs_to :card_side_front, class_name: "CardSide", foreign_key: "card_side_front_id"
  belongs_to :card_side_back, class_name: "CardSide", foreign_key: "card_side_back_id"
  has_many :filters
  has_many :postcards

  validates :shop, :card_side_front, :card_side_back, presence: true

  after_initialize :ensure_defaults

  def send_postcard?(order)
    return true unless filters.count > 0
    spend = order.total_line_items_price / 100.0
    filter = filters.first
    # if the filters are nil assume they're unbounded
    min = filter.filter_data["minimum"] || -1
    max = filter.filter_data["maximum"] || 1_000_000_000
    spend < max && spend > min
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

  def expiration_date
    return Date.today + (1 + discount_exp).weeks if type == "PostSaleOrder"
  end
end
