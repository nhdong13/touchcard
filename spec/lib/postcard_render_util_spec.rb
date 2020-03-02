require 'rails_helper'

RSpec.describe PostcardRenderUtil do

  describe "#render_postcard" do
    let(:postcard) { create(:postcard, sent: false, paid: true, card_order: card_order) }
    let(:card_order) { create(:card_order) }
    let(:shop) { card_order.shop }

    bad_png_path = (Rails.root + 'spec/images/bad_output_retina.png').to_s

    before do
      card_side_div = %(<div id="postcard-render-card-side" data-attributes="{&quot;version&quot;:0,&quot;background_url&quot;:&quot;#{(Rails.root + 'spec/images/test_color_grid.png').to_s}&quot;,&quot;discount_x&quot;:376,&quot;discount_y&quot;:56}" data-discount-pct="20" data-discount-exp="01/23/1990" data-discount-code="XXX-YYY-ZZZ"></div>)
      @sample_html = PostcardRenderSpecHelper.postcard_html(card_side_div: card_side_div)
    end

    after do
    end

    def host_extension
      case RbConfig::CONFIG['host_os']
      when /linux/
        "heroku"
      when /darwin/
        "mac"
      else
        raise "Only heroku and mac are supported in rendering tests" unless front_x.class == front_y.class
        # To support other operating systems please render the test images, manually compare, and add another option to tests
      end
    end

    def archive_test_file(file_path)
        upload_result = temp_s3_upload(File.basename(file_path), file_path)
        puts "S3 upload result: #{upload_result}"
    end

    def delete_if_exists(file_path)
      File.delete(file_path) if File.exist?(file_path)
    end

    # To manually access files in Heroku:
    #
    #   heroku run bash -a touchcard-dev-..
    #   bin/rails console
    #   output_path =  PostcardRenderUtil.render_side_png(is_front: true, postcard: Postcard.create(card_order: CardOrder.create(discount_pct: -37, discount_exp: 2, front_json: { "version":0, "background_url": "https://touchcard-static.s3.amazonaws.com/postcards/test/background_1.jpg", "discount_x":376, "discount_y":56 }), discount_pct: -37, discount_code: "XXX-YYY-ZZZ"))
    #
    #   cat /app/tmp/render/570edc23-2290-499f-98e8-e27ed9a9d993_output.png | curl -X PUT -T "-" https://transfer.sh/debug_sample_card_print.png

    context "postcard_has_discount" do
      let(:postcard) { create(:postcard,
                              sent: false,
                              paid: true,
                              card_order: card_order,
                              discount_exp_at: Time.utc(1990) + 23.days,
                              discount_code: "XXX-YYY-ZZZ",
                              discount_pct: -37) }

      it "renders_front_with_coupon" do
        output_path =  PostcardRenderUtil.render_side_png(postcard: postcard, is_front: true)
        puts "\nFront render postcard object:\n#{output_path}"
        render_matches = FileUtils.compare_file(output_path, (Rails.root + "spec/images/expected_front_coupon_#{host_extension}.png").to_s)
        archive_test_file(output_path) if ENV['HEROKU_TEST_RUN_ID'] and not render_matches
        expect(render_matches).to be_truthy  # Compare with `expected_front_coupon[...].png`
        expect(FileUtils.compare_file(output_path, bad_png_path)).to be_falsey  # Compare with bad output (confirms test)
        delete_if_exists(output_path) if render_matches
      end

      it "renders_back_without_coupon_when_postcard_has_discount_and_front_has_coupon" do
        output_path =  PostcardRenderUtil.render_side_png(postcard: postcard, is_front: false)
        puts "\nBack render postcard object:\n#{output_path}"
        render_matches = FileUtils.compare_file(output_path, (Rails.root + "spec/images/expected_back_no_coupon_#{host_extension}.png").to_s)
        expect(render_matches).to be_truthy  # Compare with `expected_back_no_coupon[...].png`
        expect(FileUtils.compare_file(output_path, bad_png_path)).to be_falsey  # Compare with bad output (confirms test)
        delete_if_exists(output_path) if render_matches
      end

      it "renders_front_without_coupon_when_postcard_is_missing_discount_pct" do
        postcard.discount_pct = nil
        output_path =  PostcardRenderUtil.render_side_png(postcard: postcard, is_front: true)
        puts "\nFront render postcard object:\n#{output_path}"
        render_matches = FileUtils.compare_file(output_path, (Rails.root + "spec/images/expected_front_no_coupon_#{host_extension}.png").to_s)
        expect(render_matches).to be_truthy  # Compare with `expected_front_no_coupon[...].png`
        expect(FileUtils.compare_file(output_path, bad_png_path)).to be_falsey  # Compare with bad output (confirms test)
        delete_if_exists(output_path) if render_matches
      end

      it "renders_back_with_coupon_at_x0_y0" do
        card_order.back_json = { "version": 0,
                                 "background_url": (Rails.root + 'spec/images/background_2.jpg').to_s,
                                 "discount_x": 0,
                                 "discount_y": 0 }
        output_path =  PostcardRenderUtil.render_side_png(postcard: postcard, is_front: false)
        puts "\nBack render postcard object:\n#{output_path}"
        render_matches = FileUtils.compare_file(output_path, (Rails.root + "spec/images/expected_back_x0_y0_coupon_#{host_extension}.png").to_s)
        archive_test_file(output_path) if ENV['HEROKU_TEST_RUN_ID'] and not render_matches
        expect(render_matches).to be_truthy  # Compare with `expected_back_no_coupon[...].png`
        expect(FileUtils.compare_file(output_path, bad_png_path)).to be_falsey  # Compare with bad output (confirms test)
        delete_if_exists(output_path) if render_matches
      end
    end

    it "renders_back_no_coupon" do
      output_path =  PostcardRenderUtil.render_side_png(postcard: postcard, is_front: false)
      puts "\nBack render postcard object:\n#{output_path}"
      render_matches = FileUtils.compare_file(output_path, (Rails.root + "spec/images/expected_back_no_coupon_#{host_extension}.png").to_s)
      expect(render_matches).to be_truthy  # Compare with `expected_back_no_coupon[...].png`
      expect(FileUtils.compare_file(output_path, bad_png_path)).to be_falsey  # Compare with bad output (confirms test)
      delete_if_exists(output_path) if render_matches
    end


    it "renders_html" do
      output_path = PostcardRenderUtil.headless_render(@sample_html, false)
      puts "\nUnthrottled html render:\n#{output_path}"
      render_matches = FileUtils.compare_file(output_path, (Rails.root + "spec/images/expected_front_test_grid_#{host_extension}.png").to_s)
      archive_test_file(output_path) if ENV['HEROKU_TEST_RUN_ID'] and not render_matches
      expect(render_matches).to be_truthy
      delete_if_exists(output_path) if render_matches
    end


    it "renders_throttled_html" do
      output_path = PostcardRenderUtil.headless_render(@sample_html, true)
      puts "\nThrottled html render:\n#{output_path}"
      render_matches = FileUtils.compare_file(output_path, (Rails.root + "spec/images/expected_front_test_grid_#{host_extension}.png").to_s)
      archive_test_file(output_path) if ENV['HEROKU_TEST_RUN_ID'] and not render_matches
      expect(render_matches).to be_truthy
      delete_if_exists(output_path) if render_matches
    end
  end
end
