require 'card_html.rb'

# This module is used for manually sending promo using `rake`. This is achieved
# by connecting to a remote DB with a local version of the app, or running rake
# on the remote environment directly.
#
# It's not perfect, but works for now. See Google Doc `SOP - Send Sample Postcard` for details

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

  def send_promo_card(card_order, lob_to_address)

    # Create a temporary postcard to call render methods
    temp_postcard = Postcard.new(card_order: card_order)
    if card_order.has_discount?
      temp_postcard.discount_code = 'SAM-PLE-XXX'
      temp_postcard.discount_exp_at = 4.weeks.from_now.midnight
      temp_postcard.discount_pct = card_order.discount_pct
    end

    front_png_path = PostcardRenderUtil.render_side_png(postcard: temp_postcard, is_front: true)
    back_png_path = PostcardRenderUtil.render_side_png(postcard: temp_postcard, is_front: false)

    @lob ||= Lob::Client.new(api_key: ENV['LOB_API_KEY'], api_version: LOB_API_VER)
    sent_postcard = @lob.postcards.create(
        description: "A Promo Sample of #{card_order.shop.domain if card_order&.shop&.domain}",
        metadata: {description: "Promo Sample for #{lob_to_address["name"] if lob_to_address && lob_to_address["name"]}"},
        to: lob_to_address,
        # from: shop_address, # Return address for Shop
        front:  File.new(front_png_path),
        back: File.new(back_png_path)
    )
    File.delete(front_png_path) if File.exist?(front_png_path)
    File.delete(back_png_path) if File.exist?(back_png_path)
    sent_postcard
  end
end
