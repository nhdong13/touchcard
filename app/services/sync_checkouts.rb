require "shopify/limit"

# Sync shopify abandoned checkouts in taouchcard databse
class SyncCheckouts
  include Shopify::Limit

  attr_reader :shop, :start_time

  def initialize(shop, start_time = Time.now)
    @shop = shop
    @start_time = start_time
  end

  def call
    return unless activate_session
    return unless checkouts_count > 0
    nb_pages = (checkouts_count / 250.0).ceil
    1.upto(nb_pages) do |page|
      wait_for_next(start_time, nb_pages)
      checkouts = api::Checkout.find( :all, params: {
                                            :limit => 250, :page => page } )
      add_to_touchcard(checkouts)
    end
  end

  private

  def add_to_touchcard(checkouts)
    checkouts.each do |checkout|
      row = Checkout.from_shopify(checkout, shop)
      byebug
      card = shop.card_orders.find_by(enabled: true, type: "AbandonedCard")
      next if card.nil?
      card.prepare_for_sending(row)
     end
  end

  def checkouts_count
    @_count ||= api::Checkout.count
  end

  def activate_session
    begin
      session = api::Session.new(shop.domain, shop.token)
      api::Base.activate_session(session)
      checkouts_count
      true
    rescue
      clear_session
      warn "Can't open session for shop #{shop.domain}"
      false
    end
  end

  def clear_session
    api::Base.clear_session
  end

  def api
    ShopifyAPI
  end
end
