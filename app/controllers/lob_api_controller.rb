class LobApiController < ApplicationController
  # This controller is used for rendering a card side to the Lob API, not via routes but ApplicationController::render
  def debug
    @lob_css_pack_path = LobRenderUtil.lob_css_pack_path
    @lob_js_pack_path = LobRenderUtil.lob_js_pack_path
    @postcard = Postcard.last
    @card_side = @postcard.card_order.card_side_front
    render :card_side
  end
end
