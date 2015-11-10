class Postcard < ActiveRecord::Base
  belongs_to :card_template
  validates :card_template_id, presence: true
  has_one :shop, through: :card_template

  # Include S3 utilities
  require 'aws_utils'

  def self.create_postcard(template_id, customer, order_id)
    card_template = CardTemplate.find(template_id)
    if card_template.type = "PostsaleTemplate"
      send_date = Date.today + card_template.send_delay.weeks
    else
      send_date = card_template.arrive_by - 1.weeks
    end
    new_card = Postcard.new(
      order_id: order_id,
      card_template: card_template.id,
      customer_id: customer.id,
      customer_name: customer.first_name + " " + customer.last_name,
      addr1: customer.default_address.address1,
      addr2: customer.default_address.address2,
      city: customer.default_address.city,
      state: customer.default_address.province_code,
      country: customer.default_address.country_code,
      zip: customer.default_address.zip,
      send_date: send_date
    )

    if new_card.save
      return new_card
    else
      # TODO: Add error logging
      return nil
    end
  end

  def send_card
    # Test lob
    @lob = Lob.load(api_key: ENV['LOB_TEST_API_KEY'])

    # Live Lob
    # @lob = Lob.load(api_key: ENV['LOB_TEST_API_KEY'])

    if (self.country == "US" and self.shop.credit >= 1) or self.shop.credit >= 2

      # Customer Address
      customer_address = {
        name: self.customer_name,
        address_line1: self.addr1,
        address_line2: self.addr2,
        address_city: self.city,
        address_state: self.state,
        address_country: self.country,
        address_zip: self.zip}


        # NOTE: For adding a return address
#       # Shop address
#       shop_address = {
#         name:
#         address_line1:
#         address_line2:
#         address_city:
#         address_state:
#         address_country:
#         address_zip: }

      if self.template == 'discount'
        generated_code = ('A'..'Z').to_a.shuffle[0,9].join
        generated_code = generated_code[0...3] + "-" + generated_code[3...6] + "-" + generated_code[6...9]
        self.shop.new_discount(generated_code)
        self.discount_code = generated_code
      end


      front_url = create_front_image(generated_code)
      back_url = create_back_image

      #begin
       sent_card = @lob.postcards.create(
         description: "A #{self.template} card sent by #{self.shop.domain}",
         to: customer_address,
         # from: shop_address, # Return address for Shop
         front: front_url,
         back: back_url
       )

       self.sent = true
       self.postcard_id = sent_card["id"]
       self.date_sent = Date.today
       self.save # TODO: Add error handling here

       # Remove images from S3
       AwsUtils.delete_from_s3(front_url)
       AwsUtils.delete_from_s3(back_url)

       # Deduct 1 credit for US, 2 for international
       if self.country == "US"
         self.shop.credit -= 1
       else
         self.shop.credit -= 2
       end
       self.shop.save

    else
      puts "No credits left on shop #{self.shop.domain}"
      #TODO possibly delete the card and S3 files here
    end
  end


  private

  def create_front_image(generated_code)
    require 'rmagick'
    unless self.card_template.image_front == nil
      bg    = Magick::ImageList.new(self.image_front)
    else
      if self.card_template.style == "discount"
        bg    = Magick::ImageList.new("#{Rails.root}/app/assets/images/discount-bg.png")
      else
        bg    = Magick::ImageList.new("#{Rails.root}/app/assets/images/thankyou-bg.png")
      end
    end
    bg.scale!(WIDTH, HEIGHT)

    if self.card_template.style == "discount"

      discount_area = Magick::Image.new(510, 300) { self.background_color = "#00000000" }
      xval = (self.card_template.discount_loc.split(",")[0].to_f/100) * WIDTH
      yval = (self.card_template.discount_loc.split(",")[1].to_f/100) * HEIGHT

      # Add text to discount area
      discount_text = self.card_template.discount_pct.to_s + "%% OFF"
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
      discount_code.annotate(discount_area, 0,0,0,0, generated_code)

      expire_text = "EXPIRE " + (Time.now + (self.card_template.discount_exp || 2).weeks).strftime("%D").to_s
      discount_expire = Magick::Draw.new
      discount_expire.font_family = 'helvetica'
      discount_expire.pointsize = 36
      discount_expire.fill = 'white'
      discount_expire.gravity = Magick::SouthGravity
      discount_expire.annotate(discount_area, 0,0,0,35, expire_text)

      # Add discount area and text to background

      bg.composite!(discount_area, xval, yval, Magick::OverCompositeOp)
    end

    # Add trim border to image
    bg.border!(38, 38, 'white')

    # Set to exactly the right size
    bg.scale!(1875, 1275)

    # Rotate to correct orientation
    bg.rotate!(-90)

    # Image save set up
    local_path = "#{Rails.root}/tmp/image_front.jpg"
    image_key = "#{self.shop.id}-image_front.jpg"

    # Save to local file system
    bg.write(local_path)

    # Upload to S3
    return AwsUtils.upload_to_s3(image_key, local_path)
  end

  def create_back_image
    require 'rmagick'
    unless self.card_template.image_back == nil
      bg = Magick::ImageList.new(self.card_template.image_back)
    else
      bg = Magick::ImageList.new("#{Rails.root}/app/assets/images/postage-area-image.png")
      bg.border!(0,0,"white")
    end

    #NOTE: For custom logo on the back
#   unless self.card_template.logo == nil
#     logo    = Magick::ImageList.new(self.card_template.logo)
#   end

    address = Magick::Image.read("#{Rails.root}/app/assets/images/address-side-clear.png").first

    # Set background to postcard size
    bg.scale!(WIDTH, HEIGHT)

    # Add logo and address area to background
    unless self.card_template.logo == nil
      bg.composite!(logo, 20, 20, Magick::OverCompositeOp)
    end
    bg.composite!(address, 0, 0, Magick::OverCompositeOp)

    # Add trim border to image
    bg.border!(38, 38, 'white')

    # Set to exactly the right size
    bg.scale!(1875, 1275)

    # Rotate to correct orientation
    bg.rotate!(-90)

    # Image save set up
    local_path = "#{Rails.root}/tmp/image_back.jpg"
    image_key = "#{self.shop.id}-image_back.jpg"

    # Save to local file system
    bg.write(local_path)

    # Upload to S3
    return AwsUtils.upload(image_key, local_path)
  end

end
