class Shop < ActiveRecord::Base
  has_one :master_card, dependent: :destroy
  has_many :cards, dependent: :destroy

  def self.store(session)
    shop = Shop.find_by(:domain => session.url)
    if shop == nil
      shop = self.new(domain: session.url, token: session.token)
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

  def self.retrieve(id)
    if shop = self.where(id: id).first
      ShopifyAPI::Session.new(shop.domain, shop.token)
    end
  end

  def shopify_api_path
    "https://#{ShopifyApp.configuration.api_key}:#{self.token}@#{self.domain}/admin"
  end

  def new_sess
    ShopifyAPI::Base.activate_session(Shop.retrieve(self.id))
  end

  def new_discount(code)
    self.new_sess
    ShopifyAPI::Discount.new(
      :type => "percentage",
      :amount => self.master_card.coupon_pct.to_i,
      :code => code,
      :ends_at => self.master_card.coupon_exp,
      :starts_at => Time.now,
      :status => enabled,
      :usage_limit => 1,
      :applies_once => true,
    )
  end


  def get_shopify_id
    # Add the shopify_id if it's empty
    if self.shopify_id == nil
      self.new_sess
      self.shopify_id = ShopifyAPI::Shop.current.id
      self.save!
    else
      return
    end
  end

  def uninstall_hook
    require 'slack_notify'
    #Add the uninstall webhook if there is none
    if self.uninstall_id == nil
      self.new_sess
      #Create new hook
      if ENV['RAILS_ENV'] == "production"
        new_hook = ShopifyAPI::Webhook.create(
          :topic    =>  "app/uninstalled",
          :format   =>  "json",
          :fields   =>  ["id", "domain"],
          :address  =>  "http://touchcard.herokuapp.com/uninstall"
           )
        self.uninstall_id = new_hook.id
        self.save!
        SlackNotify.install(self.domain)
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
    #Add the uninstall webhook if there is none
    if self.webhook_id == nil
      self.new_sess
      #Create new hook
      if ENV['RAILS_ENV'] == "production"
        new_hook = ShopifyAPI::Webhook.create(
          :topic    =>  "orders/create",
          :format   =>  "json",
          :fields   =>  ["id", "customer"],
          :address  =>  "http://touchcard.herokuapp.com/uninstall"
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

  def new_charge
    # Create a new recurring charge for the shop
    self.new_sess

    # Set the price based on last month's numbers and the % of customers to send to
    price = self.last_month * (self.customer_pct / 100) * 0.99

    #Set charge values based on environment
    if ENV['RAILS_ENV'] == "development"
      name = "Touchcard-dev"
      test = true
      return_url = "https://localhost:3000/charge/activate"
    elsif ENV['RAILS_ENV'] == "production"
      name = "Touchcard"
      test = true #TODO: Change this when app is released in Beta
      return_url = "https://touchcard.herokuapp.com/charge/activate"
    end

    #Create application charge on Shopify
    @charge = ShopifyAPI::RecurringApplicationCharge.create(
      name: name,
      price: price,
      test: test,
      return_url: return_url,
    )

    #Put some information about the new store charge in the log
    puts "*************************************"
    puts "current shop id: #{self.id}"
    puts "current shop domain: #{self.domain}"
    puts "*************************************"

    #Save the charge info to the local db and go to Shopify confirmation url
    self.charge_id = @charge.id
    self.save!

    return @charge.confirmation_url
  end

  def self.top_up_all
    # Daily top-up of all shops with today as a billing date
    @credit_shops = Shop.where(:charge_date => Date.today)
    @credit_shop.each do |shop|
      credits = (shop.charge_amount/0.99).ceil
      shop.credit += credits
      shop.save!
    end
  end

end
