module CardUtil
  module_function


  # A `lob_address` looks like this:
  # addr = {
  #   name: name,
  #   address_line1: address1,
  #   address_line2: address2,
  #   address_city: city,
  #   address_state: province_code,
  #   address_country: country_code,
  #   address_zip: zip
  # }

  # Todo: We should  probably refactor this into `send_card` and share it with `send_card` in postcard.rb
  # we could have another method for sending a promo card (or, better yet, a way to do it from ActiveAdmin)

  def send_promo_card(card_order, lob_to_address, discount_code = 'DIS-CNT-COD', expiry = 52.weeks.from_now.midnight)
    front_html, back_html = [
        card_order.card_side_front,
        card_order.card_side_back
    ].map do |card_side|
      CardHtml.generate(
          background_image: card_side.image,
          discount_x: card_side.discount_x,
          discount_y: card_side.discount_y,
          discount_pct: card_order.discount_pct,
          discount_exp: expiry.strftime("%m/%d/%Y"),
          discount_code: card_side.show_discount? ? discount_code : nil
      )
    end

    Lob.load.postcards.create(
        description: "A Promo Sample of #{card_order.shop.domain}",
        metadata: {description: "Promo Sample for #{lob_to_address[:name]}"},
        to: lob_to_address,
        # from: "Sent by Touchcard\nhttp://Touchcard.co",  # Does not pass address verification
        front: front_html,
        back: back_html
    )
  end
end
