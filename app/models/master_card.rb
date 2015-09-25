class MasterCard < ActiveRecord::Base
  belongs_to :shop
  has_many :cards, through: :shop
  validates :shop_id, presence: true


  def create_preview_front
    require 'rmagick'
    bg    = Magick::ImageList.new(self.image_front)
    bg.scale!(WIDTH, HEIGHT)

    if self.title_front != nil or self.text_front != nil
      # Add shaded area on right half of image
      shade = Magick::Image.new((bg.columns/2), bg.rows) { self.background_color = "#00000088" }

      # Add text to shaded area
      text = Magick::Draw.new
      text.font_family = 'helvetica'
      text.pointsize = 30
      text.fill = 'white'
      text.gravity = Magick::NorthWestGravity
      text.annotate(shade, 0,0,10,(bg.rows/100 * 5), self.title_front)
      text.pointsize = 18
      #text.annotate(shade, 0,0,10,(bg.rows/100 * 10), self.text_front)
      position = bg.rows/100 * 10
      message = word_wrap(self.text_front, 40)
      message.split('\n').each do |row|
        text.annotate(shade, 0, 0, 20, position += 20, row)
      end

      # Add shade and text to background
      bg.composite!(shade, (bg.columns/2), 0, Magick::OverCompositeOp)
    end

    if self.coupon_loc != nil
      #Add coupon here
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
    bg      = Magick::ImageList.new(self.image_back)
    logo    = Magick::ImageList.new(self.logo)
    address = Magick::Image.read("#{Rails.root}/app/assets/images/postage-area-image.png").first

    # Set background to postcard size
    bg.scale!(WIDTH, HEIGHT)

    # Add logo and address area to background
    bg.composite!(logo, 20, 20, Magick::OverCompositeOp)
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
