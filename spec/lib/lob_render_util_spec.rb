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
      puts "\nFront render: #{output_path}"
      mac_compare = FileUtils.compare_file(output_path, (Rails.root + 'spec/images/expected_front_coupon_mac.png').to_s)
      heroku_compare = FileUtils.compare_file(output_path, (Rails.root + 'spec/images/expected_front_coupon_heroku.png').to_s)
      gitlab_compare = FileUtils.compare_file(output_path, (Rails.root + 'spec/images/expected_front_coupon_gitlab.png').to_s)
      expect(mac_compare || heroku_compare || gitlab_compare).to be_truthy  # Compare with `expected_front_coupon[...].png`
      expect(FileUtils.compare_file(output_path, bad_png_path)).to be_falsey  # Compare with bad output (confirms test)
    end

    it "renders_back_no_coupon" do
      output_path =  LobRenderUtil.render_side_png(postcard: postcard, is_front: false)
      puts "\nBack render: #{output_path}"
      mac_compare = FileUtils.compare_file(output_path, (Rails.root + 'spec/images/expected_back_no_coupon_mac.png').to_s)
      normal_compare = FileUtils.compare_file(output_path, (Rails.root + 'spec/images/expected_back_no_coupon.png').to_s)
      expect(mac_compare || normal_compare).to be_truthy  # Compare with `expected_back_no_coupon[...].png`
      expect(FileUtils.compare_file(output_path, bad_png_path)).to be_falsey  # Compare with bad output (confirms test)
    end


    it "renders_delayed_load_correctly" do
      # TODO: Render postcard from card_order that failed in database_spec.rb
      #     { shop_id: 858, discount_x: 2, discount_y: 64, discount_pct: -20, discount_exp: 4, image: "https://touchcard-data.s3.amazonaws.com/uploads/b36efa57-a455-4cf5-81f3-b8563678296d/SOURCEvapes_1875x1275_back_2.jpg" },
      #
      # TODO: If this uses card_order this might not be the appropriate place to test it
      # TODO: So we should isolate the issue and test it where appropriate
      #  Expected behaviour with render.js:
      #   networkidle2 - fail
      #   networkidle0 - pass


      # stub_request(:post, postcard_url)
      #     .to_return(body: File.read("#{Rails.root}/spec/images/background_1.jpg"))

      postcard_url = "https://touchcard-static.s3.amazonaws.com/postcards/test/background_1.jpg"
      postcard.card_order.front_json['background_url'] = postcard_url

      postcard.discount_exp_at = Time.now + 23.days
      postcard.discount_code = "XXX-YYY-ZZZ"
      postcard.discount_pct = -37

      output_path =  LobRenderUtil.render_side_png(postcard: postcard, is_front: true)
      puts "\nFront render: #{output_path}"
      mac_compare = FileUtils.compare_file(output_path, (Rails.root + 'spec/images/expected_front_coupon_mac.png').to_s)
      heroku_compare = FileUtils.compare_file(output_path, (Rails.root + 'spec/images/expected_front_coupon_heroku.png').to_s)
      gitlab_compare = FileUtils.compare_file(output_path, (Rails.root + 'spec/images/expected_front_coupon_gitlab.png').to_s)
      expect(mac_compare || heroku_compare || gitlab_compare).to be_truthy  # Compare with `expected_front_coupon[...].png`
      expect(FileUtils.compare_file(output_path, bad_png_path)).to be_falsey  # Compare with bad output (confirms test)
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
