class LobApiController < ApplicationController
  # This controller is used for rendering a card side to the Lob API, not via routes but ApplicationController::render

  def debug  # For debugging rendering in a browser at path: /lob_debug
    # We strip off Rails.public_path because, unlike chrome headless, the browser client expects a relative path
    @lob_css_pack_path = LobRenderUtil.lob_css_pack_path.sub(Rails.public_path.to_s, '')
    @lob_js_pack_path = LobRenderUtil.lob_js_pack_path.sub(Rails.public_path.to_s, '')
    @postcard = Postcard.last
    @attributes = @postcard.card_order.front_json
    # @attributes = @postcard.card_order.back_json  # Test other side
    render :card_side
  end

end
