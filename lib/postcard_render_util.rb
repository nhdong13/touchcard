module PostcardRenderUtil
  module_function

  class PostcardRenderError < StandardError
  end


  def relative_postcard_render_js_pack_path
    path = Webpacker.manifest.lookup("postcard_render_pack.js")
    raise "Can't resolve path for postcard_render_pack.js" unless path
    path
  end

  def relative_postcard_render_css_pack_path
    path = Webpacker.manifest.lookup("postcard_render_pack.css")
    raise "Can't resolve path for postcard_render_pack.css" unless path
    path
  end


  def full_postcard_render_js_pack_path
    root = Rails.public_path
    path = relative_postcard_render_js_pack_path
    raise "Can't resolve path for postcard_render_pack.js" unless root && path
    "#{root}#{path}"
  end

  def full_postcard_render_css_pack_path
    root = Rails.public_path
    path = relative_postcard_render_css_pack_path
    raise "Error resolving path for postcard_render_pack.css" unless root && path
    "#{root}#{path}"
  end


  # Process:
  #
  # 1. Write file to local filesystem. (Mind Heroku ephemereal filesystem limitations)
  #
  # 2. Load it:
  #     driver.navigate.to file
  #
  # 3. Get DOM via: driver.execute_script("return document.documentElement.innerHTML")


  def render_side_png(postcard:, is_front:)
    begin
      html = PostcardRenderController.render_side(postcard: postcard, is_front: is_front)
      PostcardRenderUtil.headless_render(html)
    rescue PostcardRenderError
      raise "Failed to render postcard - id: #{postcard.id}"
    end
  end

  def headless_render(html, debug_network_throttle=false)
    debug_network_throttle &= !Rails.env.production?  # never throttle in production

    FileUtils.mkdir_p "#{Rails.root}/tmp/render/"
    file_name = "#{SecureRandom.uuid}"
    html_path = "#{Rails.root}/tmp/render/#{SecureRandom.uuid}_input.html"
    png_path = "#{Rails.root}/tmp/render/#{file_name}_output.png"

    File.open(html_path, 'w') {|f| f.write(html) }    # Write html to local path so Chrome can open it
    success = system("node lib/headless/render.js #{'--debug_network_throttle' if debug_network_throttle} file:///#{Shellwords.escape(html_path)} #{Shellwords.escape(png_path)}")

    raise PostcardRenderError unless success and File.exists?(png_path) && File.size(png_path) > 0

    png_path
  end

end




