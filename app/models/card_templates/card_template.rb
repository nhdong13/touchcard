class CardTemplate < ActiveRecord::Base
  belongs_to :shop
  has_many :postcards
  validates :shop_id, presence: true

  # Include S3 utilities
  require 'aws_utils'

  def self.update_all_revenues
    CardTemplate.all.each do |template|
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
        card.update_attributes(:return_customer => true, :purchase2 => new_order.total_price.to_f)

        # Add the revenue to the card_template's total
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
      if self.style == "coupon"
        bg    = Magick::ImageList.new("#{Rails.root}/app/assets/images/coupon-bg.png")
      else
        bg    = Magick::ImageList.new("#{Rails.root}/app/assets/images/thankyou-bg.png")
      end
    end
    bg.scale!(WIDTH, HEIGHT)


    if self.style == "coupon"
      coupon_area = Magick::Image.new(510, 300) { self.background_color = "#00000000" }
      xval = (self.coupon_loc.split(",")[0].to_f/100) * WIDTH
      yval = (self.coupon_loc.split(",")[1].to_f/100) * HEIGHT

      # Add text to coupon area
      coupon_text = self.coupon_pct.to_s + "%% OFF"
      coupon_off = Magick::Draw.new
      coupon_off.font_family = 'helvetica'
      coupon_off.pointsize = 72
      coupon_off.fill = 'white'
      coupon_off.gravity = Magick::NorthGravity
      coupon_off.annotate(coupon_area, 0,0,0,30, coupon_text)

      coupon_code = Magick::Draw.new
      coupon_code.font_family = 'helvetica'
      coupon_code.pointsize = 54
      coupon_code.fill = 'white'
      coupon_code.gravity = Magick::CenterGravity
      coupon_code.annotate(coupon_area, 0,0,0,0, "Coupon-Code-123")

      expire_text = "EXPIRE " + (Time.now + self.shop.send_delay.weeks + (self.coupon_exp || 2).weeks).strftime("%D").to_s
      coupon_expire = Magick::Draw.new
      coupon_expire.font_family = 'helvetica'
      coupon_expire.pointsize = 36
      coupon_expire.fill = 'white'
      coupon_expire.gravity = Magick::SouthGravity
      coupon_expire.annotate(coupon_area, 0,0,0,35, expire_text)

      # Add coupon area and text to background

      bg.composite!(coupon_area, xval, yval, Magick::OverCompositeOp)
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
