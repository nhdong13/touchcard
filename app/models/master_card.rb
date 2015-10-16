class MasterCard < ActiveRecord::Base
  belongs_to :shop
  has_many :cards, through: :shop
  validates :shop_id, presence: true


  def create_preview_front
    require 'rmagick'
    unless self.image_front == nil
      bg    = Magick::ImageList.new(self.image_front)
    else
      if self.template == "coupon"
        bg    = Magick::ImageList.new("#{Rails.root}/app/assets/images/coupon-bg.png")
      else
        bg    = Magick::ImageList.new("#{Rails.root}/app/assets/images/thankyou-bg.png")
      end
    end
    bg.scale!(WIDTH, HEIGHT)

    if self.title_front != nil or self.text_front != nil
      # Add shaded area on right half of image
      shade = Magick::Image.new((bg.columns/2), bg.rows) { self.background_color = "#00000088" }

      # Add text to shaded area
      text = Magick::Draw.new
      text.font_family = 'helvetica'
      text.pointsize = 72
      text.fill = 'white'
      text.gravity = Magick::NorthWestGravity
      text.annotate(shade, 0,0,40,60, self.title_front)
      text.pointsize = 54
      #text.annotate(shade, 0,0,10,(bg.rows/100 * 10), self.text_front)
      position = 180
      message = word_wrap(self.text_front, 36)
      message.split('\n').each do |row|
        text.annotate(shade, 0, 0, 40, position += 20, row)
      end

      # Add shade and text to background
      bg.composite!(shade, (bg.columns/2), 0, Magick::OverCompositeOp)
    end

    if self.template == "coupon"
      coupon_area = Magick::Image.new(510, 300) { self.background_color = "#00000000" }
      xval = (self.coupon_loc.split(",")[0].to_f/100) * WIDTH
      yval = (self.coupon_loc.split(",")[1].to_f/100) * HEIGHT

      # Add text to coupon area
      coupon_text = self.coupon_pct.to_s + "&#37; OFF"
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

    # Initialize S3 bucket
    obj = S3_BUCKET.object(image_key)
    obj.upload_file(local_path)

    # Set access on S3 to public
    s3 = Aws::S3::Client.new
    s3.put_object_acl(bucket: ENV['S3_BUCKET_NAME'], key: image_key, acl: 'public-read')

    # Setup variables for Shopify theme asset creation
    key = "assets\/touchcard_preview_front.jpg"
    src_url = obj.public_url.to_s
    @shop = Shop.find(self.shop_id)
    @shop.new_sess
    theme_id = ShopifyAPI::Theme.where(:role => "main")[0].id

    begin
      # Upload to Shopify theme assets and save path
      preview_front = ShopifyAPI::Asset.create({:key => key, :src => src_url, :theme_id => theme_id})
      self.preview_front = preview_front.public_url
      self.save!
      puts "Saved Front"
      S3_BUCKET.objects.delete(image_key)
    rescue
      puts "There was a problem with the image creation"
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

    unless self.logo == nil
      logo    = Magick::ImageList.new(self.logo)
    end
    address = Magick::Image.read("#{Rails.root}/app/assets/images/postage-area-image.png").first

    # Set background to postcard size
    bg.scale!(WIDTH, HEIGHT)

    # Add logo and address area to background
    unless self.logo == nil
      bg.composite!(logo, 20, 20, Magick::OverCompositeOp)
    end
    bg.composite!(address, 0, 0, Magick::OverCompositeOp)

    # if self.text_back != nil
    # Add text here
    # end

    # Image save set up
    local_path = "#{Rails.root}/tmp/preview_back.jpg"
    image_key = "#{self.shop_id}-preview_back.jpg"

    # Save to local file system
    bg.write(local_path)

    # Initialize S3 bucket
    obj = S3_BUCKET.object(image_key)
    obj.upload_file(local_path)

    # Set access on S3 to public
    s3 = Aws::S3::Client.new
    s3.put_object_acl(bucket: ENV['S3_BUCKET_NAME'], key: image_key, acl: 'public-read')

    # Setup variables for Shopify theme asset creation
    key = "assets\/touchcard_preview_back.jpg"
    src_url = obj.public_url.to_s
    @shop = Shop.find(self.shop_id)
    @shop.new_sess
    theme_id = ShopifyAPI::Theme.where(:role => "main")[0].id

    begin
      # Upload image to Shopify theme assets and save path
      preview_back = ShopifyAPI::Asset.create({:key => key, :src => src_url, :theme_id => theme_id})
      self.preview_back = preview_back.public_url
      self.save!
      puts "Saved Back"
      S3_BUCKET.objects.delete(image_key)
    rescue
      puts "There was a problem with the image creation"
    end

  end


  private


  def word_wrap(text, columns)
    # Logic to wrap text in the shaded region
    text.split("\n").collect do |line|
      line.length > columns ? line.gsub(/(.{1,#{columns}})(\s+|$)/, "\\1\n").strip : line
    end * "\n"
  end

end
