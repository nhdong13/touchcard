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
    return "international customer not enabeled" if postcard_trigger.international && !international?
    return "international customer not enabeled" if postcard_trigger.international && !international?
    return "order filtered out" unless send_postcard?(postcard_trigger)

    postcard = postcard_trigger.postcards.new(
      card_order: self,
      customer: postcard_trigger.customer,
      send_date: self.send_date,
      paid: false)
    #postcard.pay.save! if postcard.can_afford?
    if postcard.pay.save
      postcard
    else
      logger.info postcard.errors.full_messages.map{|msg| msg}.join("\n")
      false
    end
  end

  def name
    throw "Not implemented"
  end

  def description
    throw "Not implemented"
  end
end
