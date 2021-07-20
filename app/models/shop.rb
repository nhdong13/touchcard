class Shop < ApplicationRecord
  # TODO: / And now do this - understand what's changed with SessionStorage,
  # whether we should include this file or use our own (different) implementation belo
  #
  # including it throws the "no shopify_domain" error
  # not including it loads the app, but does not redirect...
  #

  has_many :card_orders, dependent: :destroy
  has_many :post_sale_orders, dependent: :destroy
  has_many :postcards, through: :card_orders
  has_many :charges
  has_many :subscriptions
  has_many :orders
  has_many :customers, through: :orders
  has_many :checkouts

  after_update :continue_sending_postcards, if: :saved_change_to_credit?

  VALID_APPROVAL_STATES = ["new", "approved", "denied"]

  validates :customer_pct, numericality: true
  validates :approval_state, inclusion: { in: VALID_APPROVAL_STATES }
  validates :approval_state, presence: true

  validates :domain, presence: true, uniqueness: { case_sensitive: false }
  validates :token, presence: true
  validates :api_version, presence: true

  def api_version
    ShopifyApp.configuration.api_version
  end

  def current_subscription
    subscriptions.last
  end

  def cards_sent
    postcards.where(sent: true).count
  end

  def revenue
    card_orders.joins(postcards: :orders).sum(:total_price)
  end

  class << self
    # Session store
    def store(session, *args)
      shop = Shop.find_by(domain: session.domain)
      if shop.nil?
        granted_scopes = ShopifyApp.configuration.scope
        shop = new(domain: session.domain, token: session.token, oauth_scopes: granted_scopes)
        shop.save!
        shop.get_shopify_id
        shop.sync_shopify_metadata
        AppInstalledJob.perform_later(shop)
      else
        shop.token = session.token
        shop.uninstalled_at = nil
        shop.save!
        shop.get_shopify_id
        ShopifyAPI::Session.new(domain: shop.domain, token: shop.token, api_version: shop.api_version)
      end
      shop.id
    end

    # Session store
    def retrieve(id)
      if shop = find_by(id: id)
        # If shop was uninstalled, we need a new session. Otherwise reinstall breaks.
        return if shop.uninstalled_at.present?
        ShopifyAPI::Session.new(
            domain: shop.domain,
            token: shop.token,
            api_version: shop.api_version
        )
      end
    end
  end

  def is_card_registered
    stripe_customer_id.present?
  end

  def stripe_customer
    Stripe::Customer.retrieve({id: stripe_customer_id, expand: ['subscriptions']})
  end

  def create_stripe_customer(token)
    if stripe_customer_id.present?
      errors.add(:stripe_token, "already added")
      return false
    end
    customer = Stripe::Customer.create(source: token)
    return update_attribute(:stripe_customer_id, customer.id) if customer
    errors.add(:stripe_token, "was invalid")
    false
  end

  def shopify_api_path
    "https://#{ShopifyApp.configuration.api_key}:#{token}@#{domain}/admin"
  end

  def new_sess
    ShopifyAPI::Base.activate_session(Shop.retrieve(id))
  end

  def get_shopify_id
    # Add the shopify_id if it's empty
    if shopify_id.nil?
      new_sess
      self.shopify_id = ShopifyAPI::Shop.current.id
      self.save!
    else
      return
    end
  end

  def top_up
    update_attribute(:credit, subscriptions.first.quantity)
  end

  def credits_used
    credit - subscriptions.first.quantity
  end

  def increment_credit
    increment!(:credit)
  end

  # Console admin method for listing all stores that have activated with Stripe
  def self.find_active
    Shop.where.not(stripe_customer_id: nil).order(:domain).select(:id, :domain, :credit)
  end

  # Console admin method for adding credits to shop with particular id
  def self.add_credit(shop_id, delta_credit)
    shop = Shop.where(id: shop_id).first
    existing_credit = shop.credit
    if defined?(Rails::Console)
      puts "Change #{shop.domain} [id: #{shop.id}] credits from #{existing_credit} to #{existing_credit + delta_credit} [Y/N]?"
      response = gets.chomp
      if not (0 == response.casecmp("y")) or (0 == response.casecmp("yes"))
        puts "Aborting"
        return
      end
    end
    shop.update_attribute(:credit, existing_credit + delta_credit)
    logger.info("Updated #{shop.domain} [id: #{shop.id}] credits from #{existing_credit} to #{shop.credit}")
  end


  def lob_address
    {
      name: self.metadata["shop_owner"],
      address_line1: self.metadata["address1"],
      address_line2: self.metadata["address2"],
      address_city: self.metadata["city"],
      address_state: self.metadata["province_code"] || self.metadata["province"],
      address_country: self.metadata["country_code"] || self.metadata["country"],
      address_zip: self.metadata["zip"]
    }
  end

  def update_last_month
    # We want to know how many first time customers ordered from the shop. This value can be misleading
    # if the shop imported data from another platform. We thus cap the number with order/processed_at,
    # which is the number of orders actually created (not imported) in the last month.
    new_sess
    start_time = Time.now - 1.month
    customers_created = ShopifyAPI::Customer.count(created_at_min: start_time)
    orders_processed = ShopifyAPI::Order.count(processed_at_min: start_time, status: "any")
    last_month = [customers_created, orders_processed].min
    update_attribute(:last_month, last_month)
  end

  # synch current shop metadata with shopify latest
  # if we are updating existing shop rails is smart enough
  # not to update columns with the same values
  def sync_shopify_metadata
    self.new_sess
    metadata                = ShopifyAPI::Shop.current
    self.name               = metadata.name
    self.email              = metadata.email
    self.customer_email     = metadata.customer_email
    self.plan_name          = metadata.plan_name
    self.owner              = metadata.shop_owner
    self.shopify_created_at = metadata.created_at
    self.shopify_updated_at = metadata.updated_at
    self.metadata           = metadata.attributes
    self.save!
  end

  def with_shopify_session(&block)
    ShopifyAPI::Session.temp(
        domain: domain,
        token: token,
        api_version: ShopifyApp.configuration.api_version,
        &block
    )
  end

  def update_scopes(scopes)
    self.oauth_scopes = scopes
    self.save!
  end


  # Filter out read_XYZ scope if we already have write_XYZ scope
  def normalized_scopes(scopes)
    scope_list = scopes.to_s.split(",").map(&:strip).reject(&:empty?).uniq
    ignore_scopes = scope_list.map { |scope| scope =~ /\Awrite_(.*)\z/ && "read_#{$1}" }.compact
    scope_list - ignore_scopes
  end

  def granted_scopes_suffice?(required_scopes)
    if oauth_scopes.present?
      required_scopes = normalized_scopes(required_scopes)
      existing_scopes = normalized_scopes(oauth_scopes)
      (required_scopes - existing_scopes).empty?
    else
      false
    end
  end

  # TODO: Unused Automations Code
  #
  # def has_customer_winback_enabled?
  #   card = card_orders.find_by(type: "CustomerWinbackOrder")
  #   card ? card.enabled : false
  # end

=begin
  def can_afford?(postcard)
    @can_afford ||= credit >= postcard.cost
  end

  def pay(postcard)
    if can_afford?(postcard) && !postcard.paid?
      self.credit -= postcard.cost
      self.save!
    else
      logger.info "not enough credits postcard:#{postcard.id}" if can_afford?(postcard)
      logger.info "already paid for postcard:#{postcard.id}" if postcard.paid?
      return false
    end
  end
=end
  def increment_credit
    increment!(:credit)
  end

  # necessary for the active admin
  def display_name
    self.domain.split('.myshopify.com').first
  end

  # 1 token = 0.89$
  # a shop with credit less than 0.89$ can put any campaign to out of credit status
  def continue_sending_postcards
    if (self.credit > 0.89 && credit_before_last_save < 0.89)
      puts CardOrder.where(shop_id: self.id, campaign_status: :out_of_credit).inspect
      CardOrder.where(shop_id: self.id, campaign_status: :out_of_credit).find_each do |campaign|
        EnableDisableCampaignService.enable_campaign campaign, "The campaign #{campaign.campaign_name} is automatically toggled to active."
      end
    end
  end

end
