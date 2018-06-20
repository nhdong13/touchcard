class CardOrder < ApplicationRecord
  TYPES = ['PostSaleOrder', 'CustomerWinbackOrder', 'LifetimePurchaseOrder', 'AbandonedCheckout']

  belongs_to :shop
  has_one :card_side_front,
          -> { where(is_back: false) },
          class_name: "CardSide",
          dependent: :destroy

  has_one :card_side_back,
          -> { where(is_back: true) },
          class_name: "CardSide",
          dependent: :destroy

  has_many :filters, dependent: :destroy
  has_many :postcards

  accepts_nested_attributes_for :card_side_front, update_only: true
  # , reject_if: :invalid_image_size
  accepts_nested_attributes_for :card_side_back, update_only: true
  # , reject_if: :invalid_image_size
  accepts_nested_attributes_for :filters,
    allow_destroy: true,
    reject_if: :all_blank

  validates :shop, :card_side_front, :card_side_back, presence: true
  validates :discount_pct, numericality: { greater_than_or_equal_to: -100,
                                           less_than: 0,
                                           only_integer: true,
                                           allow_nil: true,
                                           message: "must be between 1 and 100"}  # Customer facing value is positive. See `def discount_pct=` below

  validates :discount_exp, numericality: { greater_than_or_equal_to: 1,
                                           less_than_or_equal_to: 52,
                                           only_integer: true,
                                           allow_nil: true,
                                           message: "must be between 1 and 52 weeks"}

  delegate :current_subscription, to: :shop

  scope :active, -> { where(archived: false) }

  class << self
    def num_enabled
      CardOrder.where(enabled: true).count
    end
  end

  def send_postcard?(order)
    return true unless filters.count > 0
    spend = order.total_price / 100.0
    filter = filters.last # Somehow got a multiple-filter bug, so make sure we use latest value
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

  def redemptions
    Order.joins(:postcards).where(postcards: { card_order_id: id }).size
  end

  # TODO: Remove defaults for card_side_front & card_side_back ?
  def ensure_defaults
    self.build_card_side_front(is_back: false) unless self.card_side_front
    self.build_card_side_back(is_back: true) unless self.card_side_back
    self.send_delay = 1 if send_delay.nil? && type == "PostSaleOrder"
    self.international = false if international.nil?
    self.enabled = false if enabled.nil?
    # TODO: add defaults to schema that can be added
  end

  def shows_front_discount?
    front_json && front_json['discount_x'] && front_json['discount_y']
  end

  def shows_back_discount?
    back_json && back_json['discount_x'] && back_json['discount_y']
  end

  def has_discount?
      has_values = discount_exp.present? && discount_pct.present?
      has_values && (shows_front_discount? || shows_back_discount?)
  end

  def front_background_url
    front_json['background_url'] if front_json
  end

  # def discount?
  #   !discount_exp.nil? && !discount_pct.nil?
  # end

  def discount_pct=(val)
    write_attribute(:discount_pct, val.nil? ? nil : -(val.abs))
  end

  def discount_pct
    val = self[:discount_pct]
    val.nil? ? nil : val.abs
  end


  def send_date
    return Date.today + send_delay.weeks
    # 4-6 business days delivery according to lob
    # TODO: handle international + 5 to 7 business days
    #send_date = arrive_by - 1.week
  end

  def prepare_for_sending(postcard_trigger)
    # This method can get called from a delayed_job, which does not allow for standard logging
    # We thus return a string and expect the caller to log
    return "international customer not enabeled" if postcard_trigger.international && !international?
    return "order filtered out" unless send_postcard?(postcard_trigger)

    postcard = postcard_trigger.postcards.new(
      card_order: self,
      customer: postcard_trigger.customer,
      send_date: self.send_date,
      paid: false)
    if shop.pay(postcard)
      postcard.paid = true
      postcard.save
    else
      return postcard.errors.full_messages.map{|msg| msg}.join("\n")
    end
  end

  def archive
    self.enabled = false
    self.archived = true
    self.save!
  end

  def safe_destroy!
    self.destroy! unless postcards.exists?
  end

  private

  def invalid_image_size(attributes)
    # debugger
  end
end
