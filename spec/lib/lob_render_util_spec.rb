require 'rails_helper'

RSpec.describe LobRenderUtil do

  describe "#render_postcard" do
    let(:postcard) { create(:postcard, sent: false, paid: true, card_order: card_order) }
    let(:card_order) { create(:card_order) }
    let(:shop) { card_order.shop }

    bad_png_path = (Rails.root + 'spec/images/bad_output_retina.png').to_s

    before do
      Timecop.freeze(Time.utc(1990))
    end

    after do
      Timecop.return
    end

    it "renders_front_with_coupon" do
      postcard.discount_exp_at = Time.now + 23.days
      postcard.discount_code = "XXX-YYY-ZZZ"
      postcard.discount_pct = -37
      output_path =  LobRenderUtil.render_side_png(postcard: postcard, is_front: true)
      puts "\nFront render postcard object:\n#{output_path}"
      mac_compare = FileUtils.compare_file(output_path, (Rails.root + 'spec/images/expected_front_coupon_mac.png').to_s)
      heroku_compare = FileUtils.compare_file(output_path, (Rails.root + 'spec/images/expected_front_coupon_heroku.png').to_s)
      gitlab_compare = FileUtils.compare_file(output_path, (Rails.root + 'spec/images/expected_front_coupon_gitlab.png').to_s)
      expect(mac_compare || heroku_compare || gitlab_compare).to be_truthy  # Compare with `expected_front_coupon[...].png`
      expect(FileUtils.compare_file(output_path, bad_png_path)).to be_falsey  # Compare with bad output (confirms test)
    end

    it "renders_back_no_coupon" do
      output_path =  LobRenderUtil.render_side_png(postcard: postcard, is_front: false)
      puts "\nBack render postcard object:\n#{output_path}"
      mac_compare = FileUtils.compare_file(output_path, (Rails.root + 'spec/images/expected_back_no_coupon_mac.png').to_s)
      normal_compare = FileUtils.compare_file(output_path, (Rails.root + 'spec/images/expected_back_no_coupon.png').to_s)
      expect(mac_compare || normal_compare).to be_truthy  # Compare with `expected_back_no_coupon[...].png`
      expect(FileUtils.compare_file(output_path, bad_png_path)).to be_falsey  # Compare with bad output (confirms test)
    end


    it "renders_html" do
      html_path = Rails.root + 'spec/html/test_color_grid_input.html'
      html_doc = File.read(html_path)
      unthrottled_output_path = LobRenderUtil.headless_render(html_doc, false)
      puts "\nUnthrottled html render:\n#{unthrottled_output_path}"
      unthrottled_mac_compare = FileUtils.compare_file(unthrottled_output_path, (Rails.root + 'spec/images/expected_front_test_grid_mac.png').to_s)
      expect(unthrottled_mac_compare).to be_truthy
    end


    it "renders_throttled_html" do
      html_path = Rails.root + 'spec/html/test_color_grid_input.html'
      html_doc = File.read(html_path)
      throttled_output_path = LobRenderUtil.headless_render(html_doc, true)
      puts "\nThrottled html render:\n#{throttled_output_path}"
      throttled_mac_compare = FileUtils.compare_file(throttled_output_path, (Rails.root + 'spec/images/expected_front_test_grid_mac.png').to_s)
      expect(throttled_mac_compare).to be_truthy
    end

    it "raises_error_on_missing_data" do
      postcard.discount_exp_at = Time.now + 23.days
      # Do NOT set discount code or percentage: should throw error
      # postcard.discount_code = "XXX-YYY-ZZZ"
      # postcard.discount_pct = -37
      expect{ LobRenderUtil.render_side_png(postcard: postcard, is_front: true) }.to raise_error(LobApiController::MissingPostcardDataError)
    end
  end
end
