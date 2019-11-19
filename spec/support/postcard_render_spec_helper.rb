module PostcardRenderSpecHelper

  def self.postcard_html(js_path: PostcardRenderUtil.full_postcard_render_js_pack_path, css_path: PostcardRenderUtil.full_postcard_render_css_pack_path, card_side_div: "")
    html = File.read(Rails.root + 'spec/html/postcard_render_template.html')
    html.gsub! '__JS_PATH__', js_path
    html.gsub! '__CSS_PATH__', css_path
    html.gsub! '__CARD_SIDE_DIV__', card_side_div
    return html
  end

end
