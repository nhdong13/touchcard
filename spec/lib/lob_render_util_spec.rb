require 'rails_helper'

RSpec.describe LobRenderUtil do

  describe "#render_postcard" do
    let(:customer) { postcard.customer }
    let!(:address) { create(:address, customer: customer) }
    let(:postcard) { create(:postcard, sent: false, paid: true, card_order: card_order) }


    background1_path = (Rails.root + 'spec/images/background_1.jpg').to_s
    background2_path = (Rails.root + 'spec/images/background_2.jpg').to_s
    bad_png_path = (Rails.root + 'spec/images/bad_output_retina.png').to_s

    json_with_coupon = {
        "version":0,
        "background_url":background1_path,
        "discount_x":376,
        "discount_y":56
    }

    json_no_coupon = {
        "version":0,
        "background_url": background2_path,
        "discount_x": nil,
        "discount_y": nil
    }

    let(:card_order) { create(:card_order,
                              discount_pct: -37,
                              discount_exp: 2,
                              front_json: json_with_coupon,
                              back_json: json_no_coupon
    ) }
    let(:shop) { card_order.shop }

    before do
      Timecop.freeze(Time.local(1990))
    end

    after do
      Timecop.return
    end

    # TODO: Move these tests into LobRenderUtil...
    it "renders_front_with_coupon" do
      postcard.discount_exp_at = Time.now + 23.days
      postcard.discount_code = "XXX-YYY-ZZZ"
      postcard.discount_pct = 37
      output_path =  LobRenderUtil.render_side_png(postcard: postcard, is_front: true)
      puts "\nChecking: #{output_path}"
      retina_compare = FileUtils.compare_file(output_path, (Rails.root + 'spec/images/expected_front_coupon@2x.png').to_s)
      normal_compare = FileUtils.compare_file(output_path, (Rails.root + 'spec/images/expected_front_coupon.png').to_s)
      expect(retina_compare || normal_compare).to be_truthy  # Compare with expected output
      expect(FileUtils.compare_file(output_path, bad_png_path)).to be_falsey  # Compare with bad output (confirms test)
    end

    it "renders_back_no_coupon" do
      output_path =  LobRenderUtil.render_side_png(postcard: postcard, is_front: false)
      puts "\nChecking: #{output_path}"
      retina_compare = FileUtils.compare_file(output_path, (Rails.root + 'spec/images/expected_back_no_coupon@2x.png').to_s)
      normal_compare = FileUtils.compare_file(output_path, (Rails.root + 'spec/images/expected_back_no_coupon.png').to_s)
      expect(retina_compare || normal_compare).to be_truthy  # Compare with expected output
      expect(FileUtils.compare_file(output_path, bad_png_path)).to be_falsey  # Compare with bad output (confirms test)
    end

    it "raises_error_on_missing_data" do
      postcard.discount_exp_at = Time.now + 23.days
      # Do NOT set discount code or percentage: should throw error
      # postcard.discount_code = "XXX-YYY-ZZZ"
      # postcard.discount_pct = 37
      expect{ LobRenderUtil.render_side_png(postcard: postcard, is_front: true) }.to raise_error(LobApiController::MissingPostcardDataError)
    end
  end
end
