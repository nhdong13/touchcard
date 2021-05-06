class CardOrder < ApplicationRecord
  # TODO: Unused Automations Code
  #
  enum budget_type: [ :non_set, :monthly, :lifetime ]
  enum campaign_type: [ :automation, :one_off ]
  TYPES = ['PostSaleOrder', 'CustomerWinbackOrder', 'LifetimePurchaseOrder', 'AbandonedCheckout']
  self.inheritance_column = :_type_disabled
  belongs_to :shop

  CSV_ATTRIBUTES = %w(name type campaign_status campaign_budget campaign_schedule).freeze

  # TODO: can remove card_side relation as card side data now lives in front_json and back_json
  has_one :card_side_front,
          -> { where(is_back: false) },
          class_name: "CardSide",
          dependent: :destroy

  has_one :card_side_back,
          -> { where(is_back: true) },
          class_name: "CardSide",
          dependent: :destroy

  has_one :return_address, dependent: :destroy

  has_many :filters, dependent: :destroy
  has_many :postcards

  accepts_nested_attributes_for :card_side_front, update_only: true
  # , reject_if: :invalid_image_size
  accepts_nested_attributes_for :card_side_back, update_only: true
  # , reject_if: :invalid_image_size
  accepts_nested_attributes_for :filters,
                                allow_destroy: true,
                                reject_if: :all_blank

  accepts_nested_attributes_for :return_address,
                                allow_destroy: true

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

  after_initialize :ensure_defaults, if: :new_record?

  delegate :current_subscription, to: :shop


  default_scope { where(archived: false) }

  scope :active, -> { where(archived: false) }

  before_create :add_default_params
  after_update :update_campaign_status, if: :saved_change_to_enabled?
  after_update :update_credits, if: :saved_change_to_budget_update?
  after_update :update_budget, if: :saved_change_to_budget_type?

  def add_default_params
    self.campaign_name = "PostSaleOrder" unless self.campaign_name.present?
    self.type = "PostSaleOrder" if self.type.nil?
    self.campaign_status = "draft"
  end

  class << self
    def num_enabled
      CardOrder.where(enabled: true).count
    end
  end

  def update_budget
    current_credits = credits
    if non_set?
      update_columns(
        budget: 0,
        credits: 0,
        budget_update: 0
      )
      shop.update(credit: shop.credit + current_credits)
    end
  end

  def update_credits
    if budget.zero? && credits.zero?
      update(
        budget: budget_update,
        credits: budget_update
        )
      shop_credits = shop.credit - budget_update
      if shop_credits < budget_update
          raise "not enough token"
      else
        shop.update(credit: shop_credits)
      end
    else
      if budget_update >= budget
        new_credits = credits + (budget_update - budget)
        shop_credits = shop.credit - (budget_update - budget)
        update(
          budget: budget_update,
          credits: new_credits
        )
        shop.update(credit: shop_credits)
      else
        new_credits = credits - (budget - budget_update)
        shop_credits = shop.credit + (budget - budget_update)
        if new_credits < 0
          raise "the budget is lower than credits used."
        else
          update(
            budget: budget_update,
            credits: new_credits
          )
          shop.update(credit: shop_credits)
        end
      end
    end
  end

  def update_campaign_status
    if enabled
      self.update(campaign_status: "sending", send_date_start: DateTime.now)
      self.update(send_date_start: DateTime.now) if self.send_date_start.nil?
    else
      self.update(campaign_status: "paused", send_date_end: DateTime.now)
    end
  end

  def campaign_budget
    budget ? budget : "-"
  end

  def campaign_schedule
    "--/--"
  end

  def send_postcard?(order)
    return true unless filters.count > 0
    spend = order.total_price / 100.0
    filter = filters.last # Somehow got a multiple-filter bug, so make sure we use latest value
    # if the filters are nil assume they're unbounded
    result = true
    filter.filter_data["accepted"].each{|filter| result = result && CustomerTargetingService.new.match_filter?(order, filter)}
    filter.filter_data["removed"].each{|filter| result = result && !CustomerTargetingService.new.match_filter?(order, filter)}
    result
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
    postcards.joins(:orders).sum(:total_price)
  end

  def redemptions
    postcards.joins(:orders).size
  end

  def ensure_defaults
    self.build_card_side_front(is_back: false) unless self.card_side_front
    self.build_card_side_back(is_back: true) unless self.card_side_back
    self.international = false if international.nil?
    self.enabled = false if enabled.nil?
    # TODO: add defaults to schema that can be added
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

  def can_afford?(postcard)
    @can_afford ||= credits >= postcard.cost
  end

  def pay(postcard)
    if can_afford?(postcard) && !postcard.paid?
      self.credits -= postcard.cost
      self.save!
    else
      logger.info "not enough credits postcard:#{postcard.id}" if can_afford?(postcard)
      logger.info "already paid for postcard:#{postcard.id}" if postcard.paid?
      return false
    end
  end

  def prepare_for_sending(postcard_trigger, data_status="normal")
    # This method can get called from a delayed_job, which does not allow for standard logging
    # We thus return a string and expect the caller to log
    if data_status == "normal"
      return "international customer not enabeled" if postcard_trigger.international && !international?
    end
    return "order filtered out" unless send_postcard?(postcard_trigger)

    params = {
      card_order: self,
      customer: postcard_trigger.customer,
      paid: false
    }

    if data_status == "history"
      params.merge!({data_source_status: data_status, send_date: Date.today})
    else
      params.merge!({send_date: self.send_date})
    end

    postcard = postcard_trigger.postcards.new(params)
    if self.pay(postcard)
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

  def shows_front_discount?
    front_json && front_json['discount_x'].present? && front_json['discount_y'].present?
  end

  def shows_back_discount?
    back_json && back_json['discount_x'].present? && back_json['discount_y'].present?
  end

  # def invalid_image_size(attributes)
  #   # debugger
  # end
end
