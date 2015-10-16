class Card < ActiveRecord::Base
  belongs_to :shop
  validates :shop_id, presence: true
  has_one :master_card, through: :shop


  def self.send_all
    @to_send = Card.were("sent = ? and send_date <= ?", false, Time.now )
    @to_send.each do |card|
      #card.delay.send_card
      card.send_card
    end
  end

  def send_card
    # Test lob
    @lob = Lob.load(api_key: ENV['LOB_TEST_API_KEY'])

    # Live Lob
    # @lob = Lob.load(api_key: ENV['LOB_TEST_API_KEY'])

    if self.shop.credit >= 1

      # Customer Address
      customer_address = {
        :name             => self.customer_name,
        :address_line1    => self.addr1,
        :address_line2    => self.addr2,
        :address_city     => self.city,
        :address_state    => self.state,
        :address_country  => self.country,
        :address_zip      => self.zip}

      # # Shop address
      # shop_address = {
      #   :name             => 
      #   :address_line1    => 
      #   :address_line2    => 
      #   :address_city     => 
      #   :address_state    => 
      #   :address_country  => 
      #   :address_zip      => }

      if self.template == 'coupon'
        generated_code = ('A'..'Z').to_a.shuffle[0,9].join
        generated_code = generated_code[0...3] + "-" + generated_code[3...6] + "-" + generated_code[6...9]
        #shop = Shop.find(self.shop_id)
        #shop.new_discount(generated_code)
        self.coupon = generated_code
      end


      front_url = create_front_image(generated_code)
      back_url = create_back_image

      #begin
       sent_card = @lob.postcards.create(
         description: "A #{self.template} card sent by #{self.shop.domain}",
         to: customer_address,
         # from: shop_address,
         front: front_url,
         back: back_url,
       )

       puts sent_card

       puts "Postcard from #{self.shop.domain} sent!"

       self.sent = true
       self.postcard_id = sent_card["id"]
       self.date_sent = Date.today
       self.save

       # Remove images from S3
       delete_from_s3(front_url)
       delete_from_s3(back_url)

       # Deduct 1 credit
       self.shop.credit -= 1
       self.shop.save

      #rescue
       # puts "Postcard not sent"
      #end

    else
      puts "No credits left on shop #{self.shop.domain}"
      #TODO possibly delete the card and S3 files here
    end
  end


  private

  def create_front_image(generated_code)
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

    if self.title_back != nil or self.text_front != nil
      # Add shaded area on right half of image
      shade = Magick::Image.new((bg.columns/2), bg.rows) { self.background_color = "#00000088" }

      # Add text to shaded area
      text = Magick::Draw.new
      text.font_family = 'helvetica'
      text.pointsize = 72
      text.fill = 'white'
      text.gravity = Magick::NorthWestGravity
      text.annotate(shade, 0,0,40,60, self.title_back)
      text.pointsize = 54
      #text.annotate(shade, 0,0,10,(bg.rows/100 * 10), self.text_front)
      position = 180
      message = word_wrap(self.text_front, 40)
      message.split('\n').each do |row|
        text.annotate(shade, 0, 0, 40, position += 20, row)
      end

      # Add shade and text to background
      bg.composite!(shade, (bg.columns/2), 0, Magick::OverCompositeOp)
    end

    if self.template == "coupon"

      coupon_area = Magick::Image.new(510, 300) { self.background_color = "#00000000" }
      xval = (self.master_card.coupon_loc.split(",")[0].to_f/100) * WIDTH
      yval = (self.master_card.coupon_loc.split(",")[1].to_f/100) * HEIGHT

      # Add text to coupon area
      coupon_text = self.master_card.coupon_pct.to_s + "% OFF"
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
      coupon_code.annotate(coupon_area, 0,0,0,0, generated_code)

      expire_text = "EXPIRE " + self.master_card.coupon_exp.strftime("%D").to_s
      coupon_expire = Magick::Draw.new
      coupon_expire.font_family = 'helvetica'
      coupon_expire.pointsize = 42
      coupon_expire.fill = 'white'
      coupon_expire.gravity = Magick::SouthGravity
      coupon_expire.annotate(coupon_area, 0,0,0,15, expire_text)

      # Add coupon area and text to background

      bg.composite!(coupon_area, xval, yval, Magick::OverCompositeOp)
    end

    # Add trim border to image
    bg.border!(38, 38, 'white')

    # Set to exactly the right size
    bg.scale!(1875, 1275)

    # Rotate to correct orientation
    bg.rotate!(-90)

    # Image save set up
    local_path = "#{Rails.root}/tmp/image_front.jpg"
    image_key = "#{self.shop_id}-image_front.jpg"

    # Save to local file system
    bg.write(local_path)

    return upload_to_s3(image_key, local_path)

  end

  def create_back_image
    require 'rmagick'
    unless self.image_back == nil
      bg = Magick::ImageList.new(self.image_back)
    else
      bg = Magick::ImageList.new("#{Rails.root}/app/assets/images/postage-area-image.png")
      bg.border!(0,0,"white")
    end
    unless logo == nil
      logo    = Magick::ImageList.new(self.logo)
    end
    address = Magick::Image.read("#{Rails.root}/app/assets/images/address-side-clear.png").first

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

    # Add trim border to image
    bg.border!(38, 38, 'white')

    # Set to exactly the right size
    bg.scale!(1875, 1275)

    # Rotate to correct orientation
    bg.rotate!(-90)

    # Image save set up
    local_path = "#{Rails.root}/tmp/image_back.jpg"
    image_key = "#{self.shop_id}-image_back.jpg"

    # Save to local file system
    bg.write(local_path)

    # Upload to S3
    return upload_to_s3(image_key, local_path)
  end

  def upload_to_s3(image_key, local_path)
    begin
      # Initialize S3 bucket
      obj = S3_BUCKET.object(image_key)
      obj.upload_file(local_path)

      # Set access on S3 to public
      s3 = Aws::S3::Client.new
      s3.put_object_acl(bucket: ENV['S3_BUCKET_NAME'], key: image_key, acl: 'public-read')
    rescue
      puts "Problem with s3 upload"
    end
    return obj.public_url.to_s
  end

  def word_wrap(text, columns)
    # Logic to wrap text in the shaded region
    text.split("\n").collect do |line|
      line.length > columns ? line.gsub(/(.{1,#{columns}})(\s+|$)/, "\\1\n").strip : line
    end * "\n"
  end

  def delete_from_s3(image_url)
    S3_BUCKET.objects.each do |obj|
      if obj.public_url.to_s == image_url
        S3_BUCKET.objects.delete(obj.key)
      end
    end
  end
end
