class CardOrder < ApplicationRecord
  TYPES = ['PostSaleOrder', 'CustomerWinbackOrder', 'LifetimePurchaseOrder', 'AbandonedCheckout']

  self.inheritance_column = :_type_disabled
  belongs_to :shop

  CSV_ATTRIBUTES = %w(campaign_name type campaign_status budget schedule).freeze

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

  belongs_to :card_order_parent, :class_name => "CardOrder"
  has_many :copies, :class_name => "CardOrder", :foreign_key => "card_order_parent_id"

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
  validates :campaign_name, length: {maximum: MAXIMUM_CAMPAIGN_NAME_LENGTH}
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


  default_scope { where(archived: false) }

  scope :active, -> { where(archived: false) }

  after_initialize :ensure_defaults, if: :new_record?
  after_update :update_budget, if: :saved_change_to_budget_update?
  after_update :update_budget_type, if: :saved_change_to_budget_type?
  before_update :save_schedule_of_complete_campaign
  before_save :validate_campaign_name

  enum budget_type: [ :non_set, :monthly ]
  enum campaign_type: { automation: 0, one_off: 1 }
  enum campaign_status: { draft: 0, processing: 1, scheduled: 2, sending: 3, complete: 4, paused: 5, error: 6, out_of_credit: 7 }

  class << self
    def num_enabled
      CardOrder.where(enabled: true).count
    end
  end

  def update_budget_type
    if non_set?
      update_columns(
        budget: 0,
        budget_used: 0,
        budget_update: 0
      )
    end
  end

  def update_budget
    if budget_update < budget_used
      update(
        budget: budget_update,
        campaign_status: :paused
      )
    else
      update(budget: budget_update)
    end
  end

  def reactivate_campaign
    if self.complete? && self.automation? && Time.now.beginning_of_day <= self.send_date_end
      update(campaign_status: :sending, previous_campaign_status: CardOrder.campaign_statuses[:sending])
      # InitializeSendingPostcardProcess.start self.shop, self
    end
  end

  def send_postcard?(order)
    return true unless filters.count > 0
    spend = order.total_price / 100.0
    filter = filters.last # Somehow got a multiple-filter bug, so make sure we use latest value
    # if the filters are nil assume they're unbounded
    CustomerTargetingService.new({order: order}, filter.filter_data[:accepted], filter.filter_data[:removed]).match_filter?
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
    self.campaign_name = generate_campaign_name unless self.campaign_name.present?
    self.type = "PostSaleOrder" unless self.type.present?
    self.campaign_status = :draft
    self.filters << Filter.new(filter_data: {:accepted => {}, :removed => {}}) if self.filters.empty?
    # TODO: add defaults to schema that can be added
  end

  def has_discount?
    has_values = discount_exp.present? && discount_pct.present?
    has_values && (shows_front_discount? || shows_back_discount?)
  end

  def front_background_url
    front_json['background_url'] if front_json
  end

  def back_background_url
    back_json['background_url'] if back_json
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
    # return send_delay == 0 ? Time.now : Time.now.beginning_of_day + send_delay.weeks
    # 4-6 business days delivery according to lob
    # TODO: handle international + 5 to 7 business days
    #send_date = arrive_by - 1.week
    return send_delay == 0 ? Date.current : Date.current + send_delay.days
  end

  def prepare_for_sending(postcard_trigger)
    # This method can get called from a delayed_job, which does not allow for standard logging
    # We thus return a string and expect the caller to log
    return "international customer not enabled" if postcard_trigger.international && !international?
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
    self.save(validate: false)
  end

  def safe_destroy!
    self.destroy! unless postcards.exists?
  end

  def discount_pct_to_str
    if (back_json['discount_x'] && back_json['discount_y']) || (front_json['discount_x'] && front_json['discount_y'])
      discount_pct
    else
      "-"
    end
  end

  def discount_exp_to_str
    if (back_json['discount_x'] && back_json['discount_y']) || (front_json['discount_x'] && front_json['discount_y'])
      discount_exp
    else
      "-"
    end
  end

  def toggle_pause
    return self if self.complete?
    if self.enabled?
      update!(enabled: !self.enabled, campaign_status: :paused, previous_campaign_status: self.campaign_status_before_type_cast)
    else
      if self.can_enabled?
        if out_of_credit?
          update!(enabled: !self.enabled, campaign_status: :sending) if shop.credit > 0
        else
          if previous_campaign_status == CardOrder.campaign_statuses[:paused] || previous_campaign_status.nil?
            update!(enabled: !self.enabled)
            self.define_current_status
          else
            update!(enabled: !self.enabled, campaign_status: previous_campaign_status)
          end
        end
      end
    end
    self
  end

  def can_enabled?
    today = Time.current.to_time.to_date
    if self.automation?
      send_continuously || send_date_end >= today
    elsif self.one_off?
      send_date_start <= today
    end
  end

  def define_current_status
    today = Date.current
    if enabled
      if send_continuously
        if send_date_start > today
          update!(campaign_status: :scheduled, enabled: true)
        else
          update!(campaign_status: :sending, enabled: true)
        end
      else
        if send_date_start <= today && send_date_end >= today
          update!(campaign_status: :sending, enabled: true)
        elsif today > send_date_end
          update!(campaign_status: :complete, enabled: false)
        elsif today < send_date_start
          update!(campaign_status: :scheduled, enabled: true)
        end
      end
    end
  end

  def get_status
    return "Archived" if self.archived
    self.enabled? ? "Enabled" : "Disabled"
  end

  private
  def validate_campaign_name
    if campaign_name_changed?
      save_campaign_name = generate_campaign_name(campaign_name)
      self.campaign_name = save_campaign_name
    end
  end

  def shows_front_discount?
    front_json && front_json['discount_x'].present? && front_json['discount_y'].present?
  end

  def shows_back_discount?
    back_json && back_json['discount_x'].present? && back_json['discount_y'].present?
  end

  def generate_campaign_name exist_name=nil
    if shop.present?
      saving_name = exist_name || "Automation"
      # Case saving_name not exist
      # Return saving_name
      return saving_name unless shop.card_orders.where(campaign_name: saving_name).present?

      #Case saving_name exists
      # Step 1: Find all campaign name like saving_name with Number at the end
      exist_indexes = shop.card_orders.where("campaign_name ~* ?", saving_name + ' \d+')
                          .pluck(:campaign_name)
                          .select{|name| name != saving_name}
                          .map{|name| name.gsub(saving_name + ' ', '').to_i }
                          .sort
      # Step 2: If above query not exist, means not exist name has number at the end, then name will start with 1
      # Else find number next to last exist ending number
      unless exist_indexes.present?
        "#{saving_name} 1"
      else
        new_index = exist_indexes[-1] + 1
        (1..exist_indexes[-1] + 1).each do |i|
          unless exist_indexes.include?(i)
            new_index = i
            break
          end
        end
        "#{saving_name} #{new_index}"
      end
    else
      "Test automation"
    end
  end

  def save_schedule_of_complete_campaign
    self.campaign_status = :draft if complete? && (send_date_end_changed? || send_continuously_changed?)
  end
end
