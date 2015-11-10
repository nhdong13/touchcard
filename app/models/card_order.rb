class CardOrder < ActiveRecord::Base
  belongs_to :shop
  belongs_to :card_side_front, class_name: 'CardSide', foreign_key: 'card_side_front_id'
  belongs_to :card_side_back, class_name: 'CardSide', foreign_key: 'card_side_back_id'
  has_many :postcards

  validates :shop, :card_side_front, :card_side_back, presence: true

  # Include S3 utilities
  require 'aws_utils'

  def self.update_all_revenues
    CardOrder.all.each do |template|
      template.delay.track_revenue
    end
  end

  def track_revenue
    postcards = self.postcards
    shop = self.shop
    shop.new_sess

    postcards.each do |card|
        # TODO: refactor shopify calls to be safer and DRY-er
      begin
        customer = ShopifyAPI::Customer.find(card.customer_id)
      rescue #Shopify API limit
        wait(2)
        customer = ShopifyAPI::Customer.find(card.customer_id)
      end

      order = customer.last_order
      if order.id != card.order_id
        # TODO: refactor shopify calls to be safer and DRY-er
        begin
          new_order = ShopifyAPI::Order.find(order.id)
        rescue # Shopify API limit
          wait(2)
          new_order = ShopifyAPI::Order.find(order.id)
        end

        # Save the info in the postcard
        card.update_attributes(return_customer: true, purchase2: new_order.total_price.to_f)

        # Add the revenue to the card_order's total
        self.revenue += new_order.total_price.to_f
        self.save
      else
        # Do nothing
      end
    end
  end

  def create_preview_front
    require 'rmagick'
    unless self.image_front == nil
      bg    = Magick::ImageList.new(self.image_front)
    else
      if self.style == "discount"
        bg    = Magick::ImageList.new("#{Rails.root}/app/assets/images/discount-bg.png")
      else
        bg    = Magick::ImageList.new("#{Rails.root}/app/assets/images/thankyou-bg.png")
      end
    end
    bg.scale!(WIDTH, HEIGHT)


    if self.style == "discount"
      discount_area = Magick::Image.new(510, 300) { self.background_color = "#00000000" }
      xval = (self.discount_loc.split(",")[0].to_f/100) * WIDTH
      yval = (self.discount_loc.split(",")[1].to_f/100) * HEIGHT

      # Add text to discount area
      discount_text = self.discount_pct.to_s + "%% OFF"
      discount_off = Magick::Draw.new
      discount_off.font_family = 'helvetica'
      discount_off.pointsize = 72
      discount_off.fill = 'white'
      discount_off.gravity = Magick::NorthGravity
      discount_off.annotate(discount_area, 0,0,0,30, discount_text)

      discount_code = Magick::Draw.new
      discount_code.font_family = 'helvetica'
      discount_code.pointsize = 54
      discount_code.fill = 'white'
      discount_code.gravity = Magick::CenterGravity
      discount_code.annotate(discount_area, 0,0,0,0, "discount-Code-123")

      expire_text = "EXPIRE " + (Time.now + self.shop.send_delay.weeks + (self.discount_exp || 2).weeks).strftime("%D").to_s
      discount_expire = Magick::Draw.new
      discount_expire.font_family = 'helvetica'
      discount_expire.pointsize = 36
      discount_expire.fill = 'white'
      discount_expire.gravity = Magick::SouthGravity
      discount_expire.annotate(discount_area, 0,0,0,35, expire_text)

      # Add discount area and text to background

      bg.composite!(discount_area, xval, yval, Magick::OverCompositeOp)
    end

    # Image save set up
    local_path = "#{Rails.root}/tmp/preview_front.jpg"
    image_key = "#{self.shop_id}-preview_front.jpg"

    # Save to local file system
    bg.write(local_path)

    # Upload to S3 and save the url
    self.preview_front = AwsUtils.upload_to_s3(image_key, local_path)
    if self.save
      puts "Saved Front"
    else
      #TODO: Error handling in front save
      puts "problem saving front"
    end
  end


  def create_preview_back
    require 'rmagick'

    unless self.image_back == nil
      bg = Magick::ImageList.new(self.image_back)
    else
      bg = Magick::ImageList.new("#{Rails.root}/app/assets/images/postage-area-image.png")
      bg.border!(0,0,"white")
    end

    # NOTE: Logic for a custom logo on the back of the postcard
#   unless self.logo == nil
#     logo    = Magick::ImageList.new(self.logo)
#   end
    address = Magick::Image.read("#{Rails.root}/app/assets/images/postage-area-image.png").first

    # Set background to postcard size
    bg.scale!(WIDTH, HEIGHT)

    # Add logo and address area to background
#   unless self.logo == nil
#     bg.composite!(logo, 20, 20, Magick::OverCompositeOp)
#   end
    bg.composite!(address, 0, 0, Magick::OverCompositeOp)


    # Image save set up
    local_path = "#{Rails.root}/tmp/preview_back.jpg"
    image_key = "#{self.shop_id}-preview_back.jpg"

    # Save to local file system
    bg.write(local_path)

    # Upload to S3 and save the url
    self.preview_back = AwsUtils.upload_to_s3(image_key, local_path)
    if self.save
      puts "Saved Back"
    else
      #TODO: Error handling in back save
      puts "problem saving back"
    end
  end

  private

end
