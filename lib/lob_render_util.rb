module LobRenderUtil
  module_function

  def relative_lob_js_pack_path
    path = Webpacker.manifest.lookup("lob_render_pack.js")
    raise "Can't resolve path for lob_render_pack.js" unless path
    path
  end

  def relative_lob_css_pack_path
    path = Webpacker.manifest.lookup("lob_render_pack.css")
    raise "Can't resolve path for lob_render_pack.css" unless path
    path
  end


  def full_lob_js_pack_path
    root = Rails.public_path
    path = relative_lob_js_pack_path
    raise "Can't resolve path for lob_render_pack.js" unless root && path
    "#{root}#{path}"
  end

  def full_lob_css_pack_path
    root = Rails.public_path
    path = relative_lob_css_pack_path
    raise "Error resolving path for lob_render_pack.css" unless root && path
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
    html = LobApiController.render_side(postcard: postcard, is_front: is_front)
    LobRenderUtil.puppeteer_render(html)
  end


  def puppeteer_render(html)

    FileUtils.mkdir_p "#{Rails.root}/tmp/lob/"
    file_name = "#{Time.now.strftime('%Y%m%d%H%M%S%L')}_#{SecureRandom.uuid}"
    html_path = "#{Rails.root}/tmp/lob/#{file_name}_input.html"
    png_path = "#{Rails.root}/tmp/lob/#{file_name}_output.png"
    File.open(html_path, 'w') {|f| f.write(html) }    # Write html to local path so Chrome can open it

    # file:///Users/dustin/code/javascript/puppeteer-test/input.html
    # html_path = '/Users/dustin/code/javascript/puppeteer-test/input.html'

    system("node lib/render/headless_render.js file:///#{Shellwords.escape(html_path)} #{Shellwords.escape(png_path)}")
    png_path
  end

  def selenium_render(html)

    # Write html to local path so Chrome can open it
    FileUtils.mkdir_p "#{Rails.root}/tmp/lob/"
    file_id = SecureRandom.uuid

    file_path = "#{Rails.root}/tmp/lob/#{file_id}_input.html"
    File.open(file_path, 'w') {|f| f.write(html) }

    # Headless Chrome browsing via Selenium
    options = Selenium::WebDriver::Chrome::Options.new
    chrome_bin = ENV.fetch('GOOGLE_CHROME_SHIM', nil)
    options.binary = chrome_bin if chrome_bin # custom binary path is only for heroku
    # options.add_argument('--enable-logging --v=1')
    options.add_argument('--headless')
    options.add_argument('--window-size=1875,1275')
    options.add_argument('--no-sandbox') if Rails.env.test?  # Disable sandbox when rendering w/ Docker
    options.add_argument('--disable-dev-shm-usage') # Don't use shared memory partition
    driver = Selenium::WebDriver.for :chrome, options: options
    driver.navigate.to "file:///#{file_path}"

    # Make sure our javascript actually executed
    begin
      wait = Selenium::WebDriver::Wait.new(:timeout => 10)
      wait.until { element = driver.find_element(:css, 'div.render-complete')}
    rescue Selenium::WebDriver::Error::TimeOutError
      progress_html = driver.execute_script("return document.documentElement.innerHTML") # NOT USED
      raise "Unable to render Postcard for printing in Selenium\n\n\n #{progress_html}"
    end

    # Pull out HTML after ()javascript has formatted it)
    rendered_html = driver.execute_script("return document.documentElement.innerHTML") # NOT USED

    png_data = driver.screenshot_as :base64
    driver.quit
    png_path = "#{Rails.root}/tmp/lob/#{file_id}_output.png"
    File.open(png_path, 'wb') {|f| f.write(Base64.decode64(png_data)) }
    File.open("#{Rails.root}/tmp/lob/#{file_id}_output.html", 'wb') {|f| f.write(rendered_html) } # NOT USED

    # rendered_html - also available as return value
    png_path
  end

end




