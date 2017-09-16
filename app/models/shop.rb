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
    # Session store
    def store(session)
      shop = Shop.find_by(domain: session.url)
      if shop.nil?
        granted_scopes = ShopifyApp.configuration.scope
        shop = new(domain: session.url, token: session.token, oauth_scopes: granted_scopes)
        shop.save!
        shop.get_shopify_id
        shop.sync_shopify_metadata
        AppInstalledJob.perform_later(shop)
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
    orders_processed = ShopifyAPI::Order.count(processed_at_min: start_time)
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
  
  # necessary for the active admin
  def display_name
    self.domain
  end
end
