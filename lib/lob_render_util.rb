module LobRenderUtil
  module_function
  # def generate(options)
  # end

  # LobApiController.render :card_side, assigns: { postcard: Postcard.last, card_side: Postcard.last.card_order.card_side_front, lob_js_pack_path: LobApiController.lob_js_pack_path, lob_css_pack_path: LobApiController.lob_css_pack_path }
  #  File.open('lob_render_test.html', 'w') {|f| f.write(LobApiController.render :card_side, assigns: { postcard: Postcard.last, card_side: Postcard.last.card_order.card_side_front, lob_js_pack_path: LobApiController.lob_js_pack_path, lob_css_pack_path: LobApiController.lob_css_pack_path })}

  def lob_js_pack_path
    app_root = ENV['APP_URL']
    lob_js_path = Webpacker.manifest.lookup("lob_render_pack.js")
    raise 'Unable to find Javascript for rendering Postcard to Lob API' unless (app_root and lob_js_path)
    "#{app_root}#{lob_js_path}"
  end

  def lob_css_pack_path
    app_root = ENV['APP_URL']
    lob_css_path = Webpacker.manifest.lookup("lob_render_pack.css")
    raise 'Unable to find CSS for rendering Postcard to Lob API' unless (app_root and lob_css_path)
    "#{app_root}#{lob_css_path}"
  end

  def render_dom(html)
    # options.add_argument('--remote-debugging-port=9222')
    # driver.navigate.to "http://touchcard.ngrok.io/lob_render_test.html"
    # html = "<html><head><title>yoyo</title></head><body></body></html>"
    # driver.title
    # driver.screenshot_as :png
    # options.add_argument('--window-size=600,408')
    #

    FileUtils.mkdir_p "#{Rails.root}/public/lob/"

    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless')
    options.add_argument('--window-size=937,637')
    file_path = "#{Rails.root}/public/lob/selenium_in.html"
    File.open(file_path, 'w') {|f| f.write(html) }
    driver = Selenium::WebDriver.for :chrome, options: options

    # TODO: TEST  FILE STUFF FROM HEROKU DEV ASAP
    #
    driver.navigate.to "file:///#{file_path}"
    rendered_html = driver.execute_script("return document.documentElement.innerHTML")

    screenshot_data = driver.screenshot_as :base64
    File.open("#{Rails.root}/public/lob/selenium_out.png", 'wb') {|f| f.write(Base64.decode64(screenshot_data)) }
    File.open("#{Rails.root}/public/lob/selenium_out.html", 'wb') {|f| f.write(rendered_html) }

    rendered_html
  end


  # 1. Write file to local filesystem (careful - heroku ephemereal limitations / prefs ($HOME, /tmp) (latest stack can write anywhere, apparently).) Maybe use SecureRandom.uuid
  #
  # 2. Load it:
  #     driver.navigate.to "file:///" + pwd + "/public/lob_render_test.html"
  #
  # 3. Get DOM via something like:
  #     contents = driver.execute_script("return document.documentElement.innerHTML")
  #
  # 4. Send it to Lob
  #
  #
  #


end




