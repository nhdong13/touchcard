require "ac_integrator"
require "slack_notify"

class Shop < ActiveRecord::Base
  has_many :card_orders, dependent: :destroy
  has_many :postcards, through: :card_orders
  has_many :charges
  has_many :subscriptions
  has_many :orders

  VALID_APPROVAL_STATES = ["new", "approved", "denied"]

  validates :customer_pct, numericality: true
  validates :approval_state, inclusion: { in: VALID_APPROVAL_STATES }
  validates :approval_state, presence: true


  def current_subscription
    subscriptions.last
  end

  def cards_sent
    postcards.where(sent: true).count
  end

  def revenue
    Order.joins(postcard: :card_order)
      .where(card_orders: { shop_id: id })
      .sum(:total_price)
  end

  class << self

    # TODO: Should this should live with the session store methods?
    # TODO: Does this need to be background-tasked?
    def add_to_email_list(email)
      ac = AcIntegrator::NewInstall.new
      ac.add_email_to_list(email)
    end

    # Session store
    def store(session)
      shop = Shop.find_by(domain: session.url)
      if shop.nil?
        granted_scopes = ShopifyApp.configuration.scope
        shop = new(domain: session.url, token: session.token, oauth_scopes: granted_scopes)
        shop.save!
        shop.get_shopify_id
        shop.sync_shopify_metadata
        shop.get_last_month
        add_to_email_list(shop.email)
        SlackNotify.install(shop.domain, shop.email, shop.owner, shop.last_month, true)
      else
        shop.token = session.token
        shop.uninstalled_at = nil
        shop.save!
        shop.get_shopify_id
        ShopifyAPI::Session.new(shop.domain, shop.token)
      end
      shop.id
    end

    # Session store
    def retrieve(id)
      if shop = find_by(id: id)
        # ShopifyAPI::Session.new(shop.domain, nil)
        ShopifyAPI::Session.new(shop.domain, shop.token)
      end
    end
  end

  def is_card_registered
    stripe_customer_id.present?
  end

  def stripe_customer
    Stripe::Customer.retrieve(stripe_customer_id)
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

  def get_last_month
    new_sess
    last_month = ShopifyAPI::Customer.count(created_at_min: (Time.now - 1.month))
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
    ShopifyAPI::Session.temp(domain, token, &block)
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

  def card_last4
    return unless stripe_customer_id
    customer = Stripe::Customer.retrieve(stripe_customer_id)
    default_card_id = customer.default_source
    customer.sources["data"].find{ |x| x[:id] == default_card_id }.last4
  end

  def can_afford_postcard?
    max_send_postcards_amount ? sent_postcards_number < max_send_postcards_amount : true
  end

  def sending_active?
    current_subscription.is_active? && !current_subscription.status == "canceled"
  end

  def has_all_card_order_types?
    card_orders.pluck(:type_name).sort == CardOrder::TYPES.sort
  end

  def has_customer_winback_enabled?
    card_orders.find_by(type_name: "Customer Winback", enabled: true)
  end

  # necessary for the active admin
  def display_name
    self.domain
  end
end
