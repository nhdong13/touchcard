require "shopify/limit"

# Sync shopify abandoned checkouts in taouchcard databse
class SyncCheckouts
  attr_reader :shop, :time

  def initialize(shop, time = Time.now)
    @shop = shop
    @time = time
  end

  def call
    return unless activate_session
    return unless checkouts_count > 0
    nb_pages = (checkouts_count / 250.0).ceil
    1.upto(nb_pages) do |page|
      checkouts = api::Checkout.find( :all, params: {
                                            :created_at_min => start_time,
                                            :created_at_max => end_time,
                                            :limit => 250,
                                            :page => page } )
      add_to_touchcard(checkouts)
    end
  end

  private

  def add_to_touchcard(checkouts)
    checkouts.each do |checkout|
      row = Checkout.from_shopify(checkout, shop)
      card = shop.card_orders.find_by(enabled: true, type: "AbandonedCard")
      next if card.nil?
      card.prepare_for_sending(row)
     end
  end

  def checkouts_count
    @_count ||= api::Checkout.count(
      { :created_at_min => start_time,
        :created_at_max => end_time
      })
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

  def start_time
   @_start_time ||= time - 24.hours
  end

  def end_time
    @_end_time ||= time - 12.hours
  end
end
