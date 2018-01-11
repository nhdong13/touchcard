class LobApiController < ApplicationController
  # This controller is used for rendering a card side to the Lob API, not via routes but ApplicationController::render
  def show
  end

  # LobApiController.render :card_side, assigns: { postcard: Postcard.last, card_side: Postcard.last.card_order.card_side_front, lob_js_pack_path: LobApiController.lob_js_pack_path, lob_css_pack_path: LobApiController.lob_css_pack_path }
  #  File.open('lob_render_test.html', 'w') {|f| f.write(LobApiController.render :card_side, assigns: { postcard: Postcard.last, card_side: Postcard.last.card_order.card_side_front, lob_js_pack_path: LobApiController.lob_js_pack_path, lob_css_pack_path: LobApiController.lob_css_pack_path })}
  
  def self.lob_js_pack_path
    app_root = ENV['APP_URL']
    lob_js_path = Webpacker.manifest.lookup("lob_render_pack.js")
    raise 'Unable to find Javascript for rendering Postcard to Lob API' unless (app_root and lob_js_path)
    "#{app_root}#{lob_js_path}"
  end

  def self.lob_css_pack_path
    app_root = ENV['APP_URL']
    lob_css_path = Webpacker.manifest.lookup("lob_render_pack.css")
    raise 'Unable to find CSS for rendering Postcard to Lob API' unless (app_root and lob_css_path)
    "#{app_root}#{lob_css_path}"
  end
end
