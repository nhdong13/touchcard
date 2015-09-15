class MasterCard < ActiveRecord::Base
  belongs_to :shop
  has_many :cards, through: :shop
  validates :shop_id, presence: true

  def create_preview_front
    require 'rmagick'
    puts "past require"
    bg    = Magick::ImageList.new(self.image_front)
    puts "got past bg"

    if self.title_front != nil
      #Add title to image here
    elsif self.text_front != nil
      # Add text to image here
    end

    if self.coupon_loc != nil
      #Add coupon here
    end

    local_path = "#{Rails.root}/tmp/preview_front.jpg"
    puts local_path
    image_key = "#{self.shop_id}-preview_front.jpg"
    puts image_key

    bg.write(local_path)
    puts "wrote bg"

    # Initialize S3 bucket
    obj = S3_BUCKET.object(image_key)
    obj.upload_file(local_path)
    puts "uploaded to S3"

    # Set access on S3 to public
    s3 = Aws::S3::Client.new
    s3.put_object_acl(bucket: ENV['S3_BUCKET_NAME'], key: image_key, acl: 'public-read')
    puts "set acl"

    # Setup variables for Shopify theme asset creation
    key = "assets\/touchcard_preview_front.jpg"
    src_url = obj.public_url.to_s
    @shop = Shop.find(self.shop_id)
    @shop.new_sess
    theme_id = ShopifyAPI::Theme.where(:role => "main")[0].id

    begin
      preview_front = ShopifyAPI::Asset.create({:key => key, :src => src_url, :theme_id => theme_id})
      self.preview_front = preview_front.public_url
      self.save!
      puts "saved!!"
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

    bg.composite!(logo,   20,   20, Magick::OverCompositeOp)
    bg.composite!(address,   400,   250, Magick::OverCompositeOp)
    puts "past composite"

    if self.text_back != nil
      # Add text here
    end

    local_path = "#{Rails.root}/tmp/preview_back.jpg"
    image_key = "#{self.shop_id}-preview_back.jpg"

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
      preview_back = ShopifyAPI::Asset.create({:key => key, :src => src_url, :theme_id => theme_id})
      self.preview_back = preview_back.public_url
      self.save!
      S3_BUCKET.objects.delete(image_key)
    rescue
      puts "There was a problem with the image creation"
    end
    if self.text_back != nil
      #Add text to image here
    end

  end
end
