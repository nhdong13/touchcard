require 'rails_helper'

RSpec.describe PostcardRenderUtil do

  describe "#render_postcard" do
    let(:postcard) { create(:postcard, sent: false, paid: true, card_order: card_order) }
    let(:card_order) { create(:card_order) }
    let(:shop) { card_order.shop }

    bad_png_path = (Rails.root + 'spec/images/bad_output_retina.png').to_s

    before do
      Timecop.freeze(Time.utc(1990))

      @sample_html = File.read(Rails.root + 'spec/html/test_color_grid_input.html')
      @sample_html.gsub! '__IMAGE_PATH__', (Rails.root + 'spec/images/test_color_grid.png').to_s
      @sample_html.gsub! '__JS_PATH__', PostcardRenderUtil.full_postcard_render_js_pack_path
      @sample_html.gsub! '__CSS_PATH__', PostcardRenderUtil.full_postcard_render_css_pack_path
    end

    after do
      Timecop.return
    end

    # TODO: On heroku upload result to S3 so we can test it (like gitlab artifacts)
    #
    # In the meantime, to manually test things on Heroku:
    #
    # heroku run bash -a touchcard-dev-..
    # bin/rails console
    # output_path =  PostcardRenderUtil.render_side_png(is_front: true, postcard: Postcard.create(card_order: CardOrder.create(discount_pct: -37, discount_exp: 2, front_json: { "version":0, "background_url": "https://touchcard-static.s3.amazonaws.com/postcards/test/background_1.jpg", "discount_x":376, "discount_y":56 }), discount_pct: -37, discount_code: "XXX-YYY-ZZZ"))
    #
    # cat /app/tmp/render/570edc23-2290-499f-98e8-e27ed9a9d993_output.png | curl -X PUT -T "-" https://transfer.sh/debug_sample_card_print.png


    it "renders_front_with_coupon" do
      postcard.discount_exp_at = Time.now + 23.days
      postcard.discount_code = "XXX-YYY-ZZZ"
      postcard.discount_pct = -37
      output_path =  PostcardRenderUtil.render_side_png(postcard: postcard, is_front: true)
      puts "\nFront render postcard object:\n#{output_path}"
      mac_compare = FileUtils.compare_file(output_path, (Rails.root + 'spec/images/expected_front_coupon_mac.png').to_s)
      heroku_compare = FileUtils.compare_file(output_path, (Rails.root + 'spec/images/expected_front_coupon_heroku.png').to_s)
      gitlab_compare = FileUtils.compare_file(output_path, (Rails.root + 'spec/images/expected_front_coupon_gitlab.png').to_s)
      expect(mac_compare || heroku_compare || gitlab_compare).to be_truthy  # Compare with `expected_front_coupon[...].png`
      expect(FileUtils.compare_file(output_path, bad_png_path)).to be_falsey  # Compare with bad output (confirms test)
    end

    it "renders_back_no_coupon" do
      output_path =  PostcardRenderUtil.render_side_png(postcard: postcard, is_front: false)
      puts "\nBack render postcard object:\n#{output_path}"
      mac_compare = FileUtils.compare_file(output_path, (Rails.root + 'spec/images/expected_back_no_coupon_mac.png').to_s)
      normal_compare = FileUtils.compare_file(output_path, (Rails.root + 'spec/images/expected_back_no_coupon.png').to_s)
      expect(mac_compare || normal_compare).to be_truthy  # Compare with `expected_back_no_coupon[...].png`
      expect(FileUtils.compare_file(output_path, bad_png_path)).to be_falsey  # Compare with bad output (confirms test)
    end


    it "renders_html" do
      unthrottled_output_path = PostcardRenderUtil.headless_render(@sample_html, false)
      puts "\nUnthrottled html render:\n#{unthrottled_output_path}"
      mac_compare = FileUtils.compare_file(unthrottled_output_path, (Rails.root + 'spec/images/expected_front_test_grid_mac.png').to_s)
      heroku_compare = FileUtils.compare_file(unthrottled_output_path, (Rails.root + 'spec/images/expected_front_test_grid_heroku.png').to_s)
      expect(mac_compare || heroku_compare).to be_truthy
    end


    it "renders_throttled_html" do
      throttled_output_path = PostcardRenderUtil.headless_render(@sample_html, true)
      puts "\nThrottled html render:\n#{throttled_output_path}"
      mac_compare = FileUtils.compare_file(throttled_output_path, (Rails.root + 'spec/images/expected_front_test_grid_mac.png').to_s)
      heroku_compare = FileUtils.compare_file(throttled_output_path, (Rails.root + 'spec/images/expected_front_test_grid_heroku.png').to_s)
      expect(mac_compare || heroku_compare).to be_truthy
    end

    it "raises_error_on_missing_data" do
      postcard.discount_exp_at = Time.now + 23.days
      # Do NOT set discount code or percentage: should throw error
      # postcard.discount_code = "XXX-YYY-ZZZ"
      # postcard.discount_pct = -37
      expect{ PostcardRenderUtil.render_side_png(postcard: postcard, is_front: true) }.to raise_error(PostcardRenderController::MissingPostcardDataError)
    end
  end
end
