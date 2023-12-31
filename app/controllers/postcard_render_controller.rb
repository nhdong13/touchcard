class PostcardRenderController < ApplicationController
  # This controller is used for rendering a card side to the Lob API, not via routes but ApplicationController::render

  class MissingPostcardDataError < StandardError
  end

  # def debug  # For debugging rendering in a browser at path: /lob_debug
  #   # We strip off Rails.public_path because, unlike chrome headless, the browser client expects a relative path
  #   @lob_css_pack_path = LobRenderUtil.relative_lob_css_pack_path
  #   @lob_js_pack_path = LobRenderUtil.relative_lob_js_pack_path
  #   @postcard = Postcard.last
  #   @attributes = @postcard.card_order.front_json
  #   # @attributes = @postcard.card_order.back_json  # Test other side
  #   render :card_side
  # end

  def self.render_side (postcard:, is_front:)
    render :card_side, assigns: {
        postcard: postcard,
        json_attributes: is_front ? postcard.card_order.front_json : postcard.card_order.back_json,
        lob_js_pack_path: PostcardRenderUtil.full_postcard_render_js_pack_path,
        lob_css_pack_path: PostcardRenderUtil.full_postcard_render_css_pack_path }
  end
end
