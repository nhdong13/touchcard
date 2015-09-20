class Card < ActiveRecord::Base
  belongs_to :shop
  validates :shop_id, presence: true

  def self.send_all
    @to_send = Card.were("sent = ? and send_date <= ?", false, Time.now )
    @to_send.each do |card|
      card.delay.send
    end
  end

  def send
    @lob = Lob.load
    front_image = self.shop.master_card.preview_front
    back_image = #TODO: rmagick to create better image without address area

    # Customer Address
    customer_address = {
      :name             => self.customer_name,
      :address_line1    => self.addr1,
      :address_line2    => self.addr2,
      :address_city     => self.city,
      :address_state    => self.state,
      :address_country  => self.country,
      :address_zip      => self.zip}

    # Shop address
   #shop_address = {
   #  :name             => 
   #  :address_line1    => 
   #  :address_line2    => 
   #  :address_city     => 
   #  :address_state    => 
   #  :address_country  => 
   #  :address_zip      => }

    @lob.postcards.create(
      description: "A #{self.template} card sent by #{self.shop.domain}",
      to: customer_address,
      from: shop_address,
      front: front_image,
      back: back_image)
  end
end
