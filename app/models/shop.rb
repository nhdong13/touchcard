class Shop < ActiveRecord::Base
  validates :customer_pct, numericality: true
  has_many :card_orders, dependent: :destroy
  has_many :postcards, through: :card_orders
  has_many :charges

  class << self
    def store(session)
      shop = Shop.find_by(domain: session.url)
      if shop.nil?
        shop = new(domain: session.url, token: session.token)
        shop.save!
        shop.get_shopify_id
        shop.uninstall_hook
        shop.new_order_hook
      else
        shop.token = session.token
        shop.save!
        shop.get_shopify_id
        shop.uninstall_hook
        shop.new_order_hook
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

  def shopify_api_path
    "https://#{ShopifyApp.configuration.api_key}:#{token}@#{domain}/admin"
  end

  def new_sess
    ShopifyAPI::Base.activate_session(Shop.retrieve(id))
  end

  def new_discount(code)
    url = shopify_api_path + "/discounts.json"
    puts url

    response = HTTParty.post(url,
      body: {
        discount: {
          discount_type: "percentage",
          value: master_card.discount_pct.to_s,
          code: code,
          ends_at: (Time.now + (master_card.discount_exp || 3).weeks),
          starts_at: Time.now,
          usage_limit: 1
        }
      })
    puts response.body
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
          address: "https://touchcard.herokuapp.com/uninstall"
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
          address: "https://touchcard.herokuapp.com/new_order"
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
    credits = charge_amount
    new_credits = credit + credits
    update_attribute(:credit, new_credits)
  end

  def self.top_up_all
    # Daily top-up of all shops with today as a billing date
    shops = Shop.where(charge_date: Date.today)
    shops.each(&:top_up)
  end

  def get_last_month
    new_sess
    last_month = ShopifyAPI::Customer.count(created_at_min: (Time.now - 1.month))
    update_attribute(:last_month, last_month)
  end
end
