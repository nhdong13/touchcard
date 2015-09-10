class Shop < ActiveRecord::Base
  has_many :cards, dependent: :destroy

  def self.store(session)
    shop = self.new(domain: session.url, token: session.token)
    shop.save!
    shop.uninstall_hook
    shop.new_order_hook
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

  def uninstall_hook
    require 'slack_notify'
    #Add the uninstall webhook if there is none
    if self.uninstall_id == nil
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
end
