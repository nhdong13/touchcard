module LetterUtil
  module_function

  # A `lob_address` looks like this:
  SAMPLE_ADDRESS = { name: "Mr Recipient",
                       address_line1: "123 Main St",
                       address_line2: "",
                       address_city: "Los Angeles",
                       address_state: "CA",
                       address_country: "US",
                       address_zip: "90210" }

  SAMPLE_HTML = File.read("#{Rails.root}/spec/html/sample_color_letter.html")

  # Send a sample from Rails console:
  # LetterUtil.send_letter({ name: "Mr Recipient", address_line1: "123 Main St", address_city: "Los Angeles", address_state: "CA", address_country: "US", address_zip: "90210" }, LetterUtil::SAMPLE_ADDRESS, LetterUtil::SAMPLE_HTML)

  def send_letter(to_address, from_address, html)

    @lob ||= Lob::Client.new(api_key: ENV['LOB_API_KEY'], api_version: "2018-06-05")
    letter = @lob.letters.create(
        description: "Sample Letter for #{to_address['name']}",
        to: to_address,
        from: from_address,
        file: html,
        color: true
    )
    letter
  end
end
