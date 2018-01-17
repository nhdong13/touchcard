module LobRenderUtil
  module_function
  # def generate(options)
  # end

  # LobApiController.render :card_side, assigns: { postcard: Postcard.last, card_side: Postcard.last.card_order.card_side_front, lob_js_pack_path: LobApiController.lob_js_pack_path, lob_css_pack_path: LobApiController.lob_css_pack_path }
  #  File.open('lob_render_test.html', 'w') {|f| f.write(LobApiController.render :card_side, assigns: { postcard: Postcard.last, card_side: Postcard.last.card_order.card_side_front, lob_js_pack_path: LobApiController.lob_js_pack_path, lob_css_pack_path: LobApiController.lob_css_pack_path })}


  # def internal_lob_js_pack_path
  #   "#{Rails.public_path}#{Webpacker.manifest.lookup("lob_render_pack.js")}"
  # end

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

  def headless_render(html)

    # Write html to local path so Chrome can open it
    FileUtils.mkdir_p "#{Rails.root}/public/lob/"
    file_id = SecureRandom.uuid
    file_path = "#{Rails.root}/tmp/lob_input_#{file_id}.html"
    File.open(file_path, 'w') {|f| f.write(html) }

    # Headless Chrome browsing via Selenium
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless')
    chrome_bin = ENV.fetch('GOOGLE_CHROME_SHIM', nil)
    options.binary = chrome_bin if chrome_bin # custom binary path is only for heroku
    options.add_argument('--window-size=937,637')
    driver = Selenium::WebDriver.for :chrome, options: options
    driver.navigate.to "file:///#{file_path}"

    # Make sure our javascript actually executed
    begin
      wait = Selenium::WebDriver::Wait.new
      wait.until { element = driver.find_element(:css, 'div.render-complete')}
    rescue Selenium::WebDriver::Error::TimeOutError
      raise "Unable to render Postcard for printing in Selenium"
    end

    # Pull out HTML after ()javascript has formatted it)
    rendered_html = driver.execute_script("return document.documentElement.innerHTML")

    screenshot_data = driver.screenshot_as :base64
    File.open("#{Rails.root}/tmp/lob_output_#{file_id}.png", 'wb') {|f| f.write(Base64.decode64(screenshot_data)) }
    File.open("#{Rails.root}/tmp/lob_output_#{file_id}.html", 'wb') {|f| f.write(rendered_html) }

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




