class CardOrder < ActiveRecord::Base
  belongs_to :shop
  belongs_to :card_side_front, class_name: "CardSide", foreign_key: "card_side_front_id"
  belongs_to :card_side_back, class_name: "CardSide", foreign_key: "card_side_back_id"
  has_many :postcards

  validates :shop, :card_side_front, :card_side_back, presence: true

  after_initialize :ensure_defaults

  def ensure_defaults
    self.card_side_front ||= CardSide.create!(is_back: false)
    self.card_side_back ||= CardSide.create!(is_back: true)
    self.send_delay = 0 if send_delay.nil? && type == "PostSaleOrder"
    self.international = false if international.nil?
    self.enabled = false if enabled.nil?
    # TODO: add defaults to schema that can be added
  end

  def discount?
    !discount_exp.nil? && !discount_pct.nil?
  end

  def send_date
    return Date.today + send_delay.weeks if type == "PostSaleOrder"
    # 4-6 business days delivery according to lob
    # TODO handle international + 5 to 7 business days
    send_date = arrive_by - 1.week
  end

  def expiration_date
    return Date.today + (1 + discount_exp).weeks if type == "PostSaleOrder"
  end

  def self.update_all_revenues
    CardOrder.all.find_each(&:track_revenue)
  end

  def track_revenue
    shop.new_sess
    postcards.each do |postcard|
      # TODO: refactor shopify calls to be safer and DRY-er
      begin
        customer = ShopifyAPI::Customer.find(postcard.shopify_customer_id)
      rescue # Shopify API limit
        wait(2)
        retry
      end

      order = customer.last_order
      next unless order.id != postcard.triggering_shopify_order_id
      begin
        new_order = ShopifyAPI::Order.find(order.id)
      rescue # Shopify API limit
        wait(2)
        retry
      end

      # Save the info in the postcard
      postcard.update_attributes(return_customer: true, purchase2: new_order.total_price.to_f)

      # Add the revenue to the card_order's total
      self.revenue += new_order.total_price.to_f
      save
    end
  end
end
