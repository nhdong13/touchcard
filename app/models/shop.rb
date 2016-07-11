require "ac_integrator"

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

    def add_to_email_list(email)
      ac = AcIntegrator::NewInstall.new
      ac.add_email_to_list(email)
    end

    def store(session)
      shop = Shop.find_by(domain: session.url)
      if shop.nil?
        shop = new(domain: session.url, token: session.token)
        shop.save!
        shop.get_shopify_id
        shop.uninstall_hook
        shop.new_order_hook
        shop.sync_shopify_metadata
        add_to_email_list(shop.email)
      else
        shop.token = session.token
        shop.save!
        shop.get_shopify_id
        shop.uninstall_hook
        shop.new_order_hook
        shop.sync_shopify_metadata
        ShopifyAPI::Session.new(shop.domain, shop.token)
      end
      shop.id
    end

    def retrieve(id)
      if shop = find_by(id: id)
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

  def new_discount(percent, expiration, code)
    url = shopify_api_path + "/discounts.json"
    response = HTTParty.post(url,
      body: {
        discount: {
          discount_type: "percentage",
          value: percent.to_s,
          code: code,
          ends_at: expiration,
          starts_at: Time.now,
          usage_limit: 1
        }
      })
    logger.info response.body
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


  def uninstall_hook
    require "slack_notify"
    # Add the uninstall webhook if there is none
    if uninstall_id.nil?
      new_sess
      # Create new hook
      if ENV["RAILS_ENV"] == "production"
        new_hook = ShopifyAPI::Webhook.create(
          topic: "app/uninstalled",
          format: "json",
          fields: %w(id domain),
          address: "#{ENV['APP_URL']}/uninstall"
        )
        self.uninstall_id = new_hook.id
        self.save!
        SlackNotify.install(domain)
        return
      else
        # Skip if not production environment
        return
      end
    else
      # Skip if there is a hook already
      return
    end
  end

  def new_order_hook
    # Add the uninstall webhook if there is none
    if webhook_id.nil?
      new_sess
      # Create new hook
      if ENV["RAILS_ENV"] == "production"
        new_hook = ShopifyAPI::Webhook.create(
          topic: "orders/create",
          format: "json",
          fields: %w(id customer),
          address: "#{ENV['APP_URL']}/new_order"
        )
        self.webhook_id = new_hook.id
        self.save!
        return
      else
        # Skip if not production environment
        return
      end
    else
      # Skip if there is a hook already
      return
    end
  end

  def top_up
    update_attribute(:credit, subscriptions.first.quantity)
    unless subscriptions.blank?
      subscriptions.last.update_attributes(
        current_period_start: Time.now.beginning_of_month,
        current_period_end:   Time.now + 1.month
      )
    end
  end

  def credits_used
    credit - subscriptions.first.quantity
  end

  def self.top_up_all
    # Daily top-up of all shops with today as a billing date
    # shops = Shop.where(charge_date: Date.today)
    # shops.each(&:top_up)
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
    self.save!
  end
end
